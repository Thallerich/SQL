DROP TABLE IF EXISTS #TmpLsKontrolle888d;

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS VsaBezeichnung, CONVERT(varchar(10), NULL) AS LsNr, CONVERT(date, NULL) AS Datum, AnfKo.AuftragsNr AS Packzettelnummer, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, ArtGroe.Groesse AS Größe, IIF(DATEDIFF(minute, AnfPo.Anlage_, AnfPo.BestaetZeitpunkt) = 0, 0, AnfPo.Angefordert) AS Angefordert, 0 AS Liefermenge, 0 AS AnzahlChips, 0 AS Abweichung, CONVERT(numeric(7,2), 0) AS AbweichungProzent, CONVERT(bit, IIF(KdArti_2.Vorlaeufig = 1 AND KdArti_2.AnlageUserID_ IN (SELECT Mitarbei.ID FROM Mitarbei WHERE Mitarbei.UserName IN ('TAGJOB', 'CITJOB')), 1, 0)) AS NichtKdArti, CONVERT(bit, 0) AS LsIsOK, CONVERT(bit, IIF(KdArti_1.ErsatzFuerKdArtiID > 0, 1, 0)) AS IstErsatz, KdArti_1.ID AS OrigKdArtiID, AnfKo.LsKoID, AnfPo.ID AS AnfPoID, Vsa.ID AS VsaID, KdArti_2.KdBerID, AnfPo.ArtGroeID
INTO #TmpLsKontrolle888d
FROM AnfPo, AnfKo, Vsa, Kunden, KdArti AS KdArti_1, KdArti AS KdArti_2, Artikel, ArtGroe
WHERE AnfPo.AnfKoID = AnfKo.ID
  AND AnfKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND AnfPo.KdArtiID = KdArti_1.ID
  AND ((KdArti_1.ErsatzFuerKdArtiID < 0 AND KdArti_1.ID = KdArti_2.ID) OR (KdArti_1.ErsatzFuerKdArtiID > 0 AND KdArti_1.ErsatzFuerKdArtiID = KdArti_2.ID))
  AND KdArti_2.ArtikelID = Artikel.ID
  AND AnfPo.ArtGroeID = ArtGroe.ID
  AND AnfKo.Lieferdatum BETWEEN $1$ AND $2$
  AND (AnfPo.Angefordert > 0 OR AnfPo.Geliefert > 0)
  AND AnfKo.Status >= 'I'
  AND Vsa.StandKonID IN ($4$)
  AND ((Artikel.EAN IS NOT NULL AND $3$ = 1) OR ($3$ = 0))
  AND (($6$ = 1 AND Artikel.ArtikelNr NOT IN (N'111260022001', N'111260020001')) OR ($6$ = 0))  -- Artikel 111260022001, 111260020001 - Ticket 17910 / ticket 19345
;

UPDATE LsKontrolle SET LsNr = CONVERT(varchar(10), LsKo.LsNr), Datum = LsKo.Datum
FROM #TmpLsKontrolle888d LsKontrolle, LsKo
WHERE LsKontrolle.LsKoID = LsKo.ID
  AND LsKontrolle.LsKoID > 0;

UPDATE LsKontrolle SET LsKontrolle.Liefermenge = LsPo.Menge
FROM #TmpLsKontrolle888d LsKontrolle, LsPo, LsKo
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKontrolle.LsKoID = LsKo.ID
  AND LsKontrolle.OrigKdArtiID = LsPo.KdArtiID
  AND LsKontrolle.ArtGroeID = LsPo.ArtGroeID
  AND LsKontrolle.LsKoID > 0;

UPDATE #TmpLsKontrolle888d
SET Abweichung = Liefermenge - Angefordert, AbweichungProzent = CONVERT(numeric(7,2), Liefermenge - Angefordert) / CONVERT(numeric(7,2), IIF(Angefordert = 0, 1, Angefordert));

UPDATE LsKontrolle SET LsKontrolle.AnzahlChips = x.AnzahlChips
FROM #TmpLsKontrolle888d LsKontrolle, (
  SELECT COUNT(DISTINCT Scans.EinzTeilID) AS AnzahlChips, Scans.AnfPoID
  FROM Scans, #TmpLsKontrolle888d LSK
  WHERE Scans.AnfPoID = LSK.AnfPoID
  GROUP BY Scans.AnfPoID
) x
WHERE x.AnfPoID = LsKontrolle.AnfPoID;

SELECT LSK.KdNr, LSK.Kunde, LSK.VsaStichwort, LSK.VsaBezeichnung, LSK.ArtikelNr, LSK.ArtikelBez AS Artikelbezeichnung, LSK.Größe, LSK.Angefordert, LSK.Liefermenge, LSK.AnzahlChips, LSK.Abweichung, FORMAT(LSK.AbweichungProzent, 'P2', 'de-AT') AS [Abweichung %], LSK.LsNr AS Lieferschein, LSK.Datum AS Lieferdatum, LSK.Packzettelnummer AS Packzettel, LSK.IstErsatz AS [Ersatzartikel geliefert]
FROM #TmpLsKontrolle888d LSK
WHERE (
    ($5$ = 0 AND LSK.Abweichung <> 0) 
    OR ($5$ = 0 AND LSK.IstErsatz = 1)
    OR ($5$ = 1)
  )
ORDER BY LSK.KdNr, LSK.VsaStichwort, Packzettel;