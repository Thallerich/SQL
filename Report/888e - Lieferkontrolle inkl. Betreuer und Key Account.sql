DROP TABLE IF EXISTS #TmpLsKontrolle888e;

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS VsaBezeichnung, CONVERT(varchar(10), NULL) AS LsNr, CONVERT(date, NULL) AS Datum, AnfKo.AuftragsNr AS Packzettelnummer, CONVERT(char(15), NULL) AS ArtikelNr, CONVERT(nvarchar(60), NULL) AS ArtikelBez, ArtGroe.Groesse AS Größe, IIF((VsaBer.AnfAusEpo > 1 OR KdBer.AnfAusEPo > 1 OR Kunden.CheckPackmenge = 1) AND AnfPo.Angefordert % COALESCE(NULLIF(ArtiStan.PackMenge, -1), Artikel.PackMenge) != 0 AND AnfPo.Angefordert = 1, 0, AnfPo.Angefordert) AS Angefordert, 0 AS Liefermenge, 0 AS AnzahlChips, 0 AS Abweichung, CONVERT(numeric(7,2), 0) AS AbweichungProzent, CONVERT(bit, 0) AS NichtKdArti, CONVERT(bit, IIF(KdArti.ErsatzFuerKdArtiID > 0, 1, 0)) AS IstErsatz, KdArti.ID AS OrigKdArtiID, KdArti.ErsatzFuerKdArtiID, IIF(KdArti.ErsatzFuerKdArtiID > 0, KdArti.ErsatzFuerKdArtiID, KdArti.ID) AS KdArtiID, CONVERT(bit, 0) AS IstFalschlieferung, AnfKo.LsKoID, AnfPo.ID AS AnfPoID, AnfPo.Kostenlos, Vsa.ID AS VsaID, NULL AS KdBerID, NULL AS ArtikelID, AnfPo.ArtGroeID
INTO #TmpLsKontrolle888e
FROM AnfPo
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN Vsa ON AnfKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID
JOIN ArtGroe ON AnfPo.ArtGroeID = ArtGroe.ID
JOIN VsaBer ON AnfKo.VsaID = VsaBer.VsaID AND KdArti.KdBerID = VsaBer.KdBerID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN LsKo ON AnfKo.LsKoID = LsKo.ID
LEFT JOIN LsPo ON LsPo.LsKoID = LsKo.ID AND AnfPo.KdArtiID = LsPo.KdArtiID AND AnfPo.ArtGroeID = LsPo.ArtGroeID AND AnfPo.VpsKoID = LsPo.VpsKoID AND AnfPo.LsKoGruID = LsPo.LsKoGruID AND AnfPo.Kostenlos = LsPo.Kostenlos
LEFT JOIN ArtiStan ON ArtiStan.ArtikelID = Artikel.ID AND AnfKo.ProduktionID = ArtiStan.StandortID
WHERE AnfKo.Lieferdatum = $1$
  AND (IIF((VsaBer.AnfAusEpo > 1 OR KdBer.AnfAusEPo > 1 OR Kunden.CheckPackmenge = 1) AND AnfPo.Angefordert % COALESCE(NULLIF(ArtiStan.PackMenge, -1), Artikel.PackMenge) != 0 AND AnfPo.Angefordert = 1, 0, AnfPo.Angefordert) > 0 OR (AnfPo.Geliefert > 0 OR ISNULL(LsPo.Menge, 0) > 0))
  AND AnfKo.Status >= N'I'
  AND Vsa.StandKonID IN ($3$)
;

UPDATE LsKontrolle SET ArtikelNr = Artikel.ArtikelNr, ArtikelBez = Artikel.ArtikelBez$LAN$, NichtKdArti = IIF(KdArti.Vorlaeufig = 1 AND KdArti.AnlageUserID_ IN (SELECT Mitarbei.ID FROM Mitarbei WHERE Mitarbei.UserName IN (N'TAGJOB', N'CITJOB')), 1, 0), KdBerID = KdArti.KdBerID, ArtikelID = Artikel.ID
FROM #TmpLsKontrolle888e LsKontrolle, KdArti, Artikel, Bereich
WHERE LsKontrolle.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID;

DELETE FROM #TmpLsKontrolle888e
WHERE KdBerID IN (SELECT KdBer.ID FROM KdBer, Bereich WHERE KdBer.BereichID = Bereich.ID AND Bereich.Bereich = N'LW');

DELETE FROM #TmpLsKontrolle888e
WHERE ArtikelID <= 0;

DELETE FROM #TmpLsKontrolle888e
WHERE $5$ = 1 
  AND ArtikelNr IN (N'111260022001', N'111260020001');  -- Ticket 17910 / ticket 19345

DELETE FROM #TmpLsKontrolle888e
WHERE ArtikelID IN (SELECT Artikel.ID FROM Artikel WHERE Artikel.EAN IS NULL AND $2$ = 1);

UPDATE LsKontrolle SET LsNr = CONVERT(varchar(10), LsKo.LsNr), Datum = LsKo.Datum
FROM #TmpLsKontrolle888e LsKontrolle, LsKo
WHERE LsKontrolle.LsKoID = LsKo.ID
  AND LsKontrolle.LsKoID > 0;

UPDATE LsKontrolle SET LsKontrolle.Liefermenge = LsPo.Menge
FROM #TmpLsKontrolle888e LsKontrolle, LsPo, LsKo
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKontrolle.LsKoID = LsKo.ID
  AND LsKontrolle.OrigKdArtiID = LsPo.KdArtiID
  AND LsKontrolle.Kostenlos = LsPo.Kostenlos
  AND LsKontrolle.ArtGroeID = LsPo.ArtGroeID
  AND LsKontrolle.LsKoID > 0;

UPDATE #TmpLsKontrolle888e
SET Abweichung = Liefermenge - Angefordert, AbweichungProzent = CONVERT(numeric(7,2), Liefermenge - Angefordert) / CONVERT(numeric(7,2), IIF(Angefordert = 0, 1, Angefordert));

UPDATE LsKontrolle SET LsKontrolle.AnzahlChips = x.AnzahlChips
FROM #TmpLsKontrolle888e LsKontrolle, (
  SELECT COUNT(DISTINCT Scans.EinzTeilID) AS AnzahlChips, Scans.AnfPoID
  FROM Scans, #TmpLsKontrolle888e LSK
  WHERE Scans.AnfPoID = LSK.AnfPoID
  GROUP BY Scans.AnfPoID
) x
WHERE x.AnfPoID = LsKontrolle.AnfPoID;

UPDATE LsKontrolle SET IstFalschlieferung = 1
FROM #TmpLsKontrolle888e LsKontrolle, Scans, EinzTeil
WHERE Scans.AnfPoID = LsKontrolle.AnfPoID
  AND Scans.EinzTeilID = EinzTeil.ID
  AND EinzTeil.VsaOwnerID > 0
  AND EinzTeil.VsaOWnerID <> LsKontrolle.VsaID;

SELECT Kundenservice.Name AS Kundenservice, Betreuer.Name AS Kundenbetreuer, Vertrieb.Name AS [Key Account], LSK.KdNr, LSK.Kunde, LSK.VsaStichwort, LSK.VsaBezeichnung, LSK.ArtikelNr, LSK.ArtikelBez AS Artikelbezeichnung, LSK.Größe, LSK.Angefordert, LSK.Liefermenge, LSK.AnzahlChips, LSK.Abweichung, FORMAT(LSK.AbweichungProzent, N'P2', N'de-AT') AS [Abweichung %], LSK.LsNr AS Lieferschein, LSK.Datum AS Lieferdatum, LSK.Packzettelnummer AS Packzettel, LSK.IstErsatz AS [Ersatzartikel geliefert], LSK.IstFalschlieferung AS [Lieferung nicht an Eigentümer]
FROM #TmpLsKontrolle888e LSK, KdBer, Mitarbei AS Betreuer, Mitarbei AS Vertrieb, Mitarbei AS Kundenservice
WHERE LSK.KdBerID = KdBer.ID
  AND KdBer.BetreuerID = Betreuer.ID
  AND KdBer.VertreterID = Vertrieb.ID
  AND KdBer.ServiceID = Kundenservice.ID
  AND (
    ($4$ = 0 AND LSK.Abweichung <> 0) 
    OR ($4$ = 0 AND LSK.IstErsatz = 1)
    OR ($4$ = 1)
  )
ORDER BY LSK.KdNr, LSK.VsaStichwort, Packzettel;