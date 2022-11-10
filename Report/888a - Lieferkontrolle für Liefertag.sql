DROP TABLE IF EXISTS #TmpLsKontrolle888a;

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS VsaBezeichnung, CONVERT(varchar(10), NULL) AS LsNr, CONVERT(date, NULL) AS Datum, AnfKo.AuftragsNr AS Packzettelnummer, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, ArtGroe.Groesse AS Größe, IIF(DATEDIFF(minute, AnfPo.Anlage_, AnfPo.BestaetZeitpunkt) = 0, 0, AnfPo.Angefordert) AS Angefordert, 0 AS Liefermenge, 0 AS AnzahlChips, 0 AS Abweichung, CONVERT(numeric(7,2), 0) AS AbweichungProzent, IIF(KdArti.Vorlaeufig = 1 AND KdArti.AnlageUserID_ IN (SELECT Mitarbei.ID FROM Mitarbei WHERE Mitarbei.UserName IN ('TAGJOB', 'CITJOB')), 1, 0) AS NichtKdArti, 0 AS LsIsOK, AnfPo.KdArtiID, AnfKo.LsKoID, AnfPo.ID AS AnfPoID, Vsa.ID AS VsaID, AnfPo.ArtGroeID
INTO #TmpLsKontrolle888a
FROM AnfPo, AnfKo, Vsa, Kunden, KdArti, Artikel, ArtGroe
WHERE AnfPo.AnfKoID = AnfKo.ID
  AND AnfKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND AnfPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND AnfPo.ArtGroeID = ArtGroe.ID
  AND AnfKo.Lieferdatum = $1$
  AND (AnfPo.Angefordert > 0 OR AnfPo.Geliefert > 0)
  AND AnfKo.Status >= 'I'
  AND Vsa.StandKonID IN ($3$)
  AND ((Artikel.EAN IS NOT NULL AND $2$ = 1) OR ($2$ = 0))
  AND Artikel.ArtikelNr NOT IN ('111260022001', '111260020001')  -- Artikel 111260022001, 111260020001 - Ticket 17910
;

UPDATE LsKontrolle SET LsNr = CONVERT(varchar(10), LsKo.LsNr), Datum = LsKo.Datum
FROM #TmpLsKontrolle888a LsKontrolle, LsKo
WHERE LsKontrolle.LsKoID = LsKo.ID
  AND LsKontrolle.LsKoID > 0;

UPDATE LsKontrolle SET LsKontrolle.Liefermenge = LsPo.Menge
FROM #TmpLsKontrolle888a LsKontrolle, LsPo, LsKo
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKontrolle.LsKoID = LsKo.ID
  AND LsKontrolle.KdArtiID = LsPo.KdArtiID
  AND LsKontrolle.ArtGroeID = LsPo.ArtGroeID
  AND LsKontrolle.LsKoID > 0;

UPDATE #TmpLsKontrolle888a
SET Abweichung = Liefermenge - Angefordert, AbweichungProzent = CONVERT(numeric(7,2), Liefermenge - Angefordert) / CONVERT(numeric(7,2), IIF(Angefordert = 0, 1, Angefordert));

UPDATE LsKontrolle SET LsKontrolle.AnzahlChips = x.AnzahlChips
FROM #TmpLsKontrolle888a LsKontrolle, (
  SELECT COUNT(DISTINCT Scans.EinzTeilID) AS AnzahlChips, Scans.AnfPoID
  FROM Scans, #TmpLsKontrolle888a LSK
  WHERE Scans.AnfPoID = LSK.AnfPoID
  GROUP BY Scans.AnfPoID
) x
WHERE x.AnfPoID = LsKontrolle.AnfPoID;

SELECT KdNr, Kunde, VsaStichwort, VsaBezeichnung, LsNr, Datum, Packzettelnummer, ArtikelNr, ArtikelBez, Größe, Angefordert, Liefermenge, AnzahlChips, Abweichung, FORMAT(AbweichungProzent, 'P2', 'de-AT') AS AbweichungProzent, NichtKdArti, LsIsOK, KdArtiID, LsKoID, AnfPoID, VsaID
FROM #TmpLsKontrolle888a LSK
WHERE Abweichung <> 0
ORDER BY KdNr, VsaStichwort, Packzettelnummer, NichtKdArti;