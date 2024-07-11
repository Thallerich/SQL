/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: GetData                                                                                                         ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #TmpLsKontrolle888h;

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS VsaBezeichnung, AnfKo.AuftragsNr AS Packzettelnummer, AnfKo.Lieferdatum, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, ArtGroe.Groesse AS Größe, AnfPo.Angefordert, COALESCE(IIF(ArtiStan.Packmenge <= 0, NULL, ArtiStan.Packmenge), Artikel.Packmenge) AS Packmenge, VsaAnf.Durchschnitt, AnfPo.ID AS AnfPoID, Vsa.ID AS VsaID, Artikel.ID AS ArtikelID, AnfPo.ArtGroeID, VsaBer.BetreuerID, VsaBer.VertreterID, VsaBer.ServiceID
INTO #TmpLsKontrolle888h
FROM AnfPo
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN Vsa ON AnfKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN VsaBer ON VsaBer.VsaID = Vsa.ID AND VsaBer.KdBerID = KdBer.ID
JOIN ArtGroe ON AnfPo.ArtGroeID = ArtGroe.ID
JOIN VsaAnf ON AnfKo.VsaID = VsaAnf.VsaID AND AnfPo.KdArtiID = VsaAnf.KdArtiID AND AnfPo.ArtGroeID = VsaAnf.ArtGroeID
LEFT JOIN ArtiStan ON ArtiStan.ArtikelID = Artikel.ID AND ArtiStan.StandortID = AnfKo.ProduktionID
WHERE AnfKo.Lieferdatum > CAST(GETDATE() AS date)
  AND (AnfPo.Angefordert > 0 OR VsaAnf.Durchschnitt > 0)
  AND AnfKo.Status = N'I'
  AND AnfKo.Sonderfahrt = 0
  AND VsaAnf.Status = N'A'
  AND Vsa.StandKonID IN ($1$)
  AND Artikel.ID > 0
  AND KdBer.BereichID != (SELECT Bereich.ID FROM Bereich WHERE Bereich = N'LW');

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: Anf-Check                                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Kundenservice.Name AS Kundenservice,
  Betreuer.Name AS Kundenbetreuer,
  Vertrieb.Name AS [Key Account],
  LSK.KdNr,
  LSK.Kunde,
  LSK.VsaStichwort,
  LSK.VsaBezeichnung,
  LSK.ArtikelNr,
  LSK.ArtikelBez AS Artikelbezeichnung,
  LSK.Größe,
  LSK.Angefordert,
  LSK.Durchschnitt,
  /* ROUND(LSK.Durchschnitt / CAST(LSK.Packmenge AS float), 0) * CAST(LSK.Packmenge AS int) AS Durchschnitt, */
  LSK.Angefordert - LSK.Durchschnitt AS Abweichung,
  /* ROUND(LSK.Durchschnitt / CAST(LSK.Packmenge AS float), 0) * CAST(LSK.Packmenge AS int) - LSK.Angefordert AS Abweichung, */
  FORMAT(CONVERT(numeric(7,2), (LSK.Angefordert - LSK.Durchschnitt)) / CONVERT(numeric(7,2), IIF(LSK.Angefordert = 0, 1, LSK.Angefordert)), N'P2', N'de-AT') AS [Abweichung %],
  /* FORMAT(CONVERT(numeric(7,2), ROUND(LSK.Durchschnitt / CAST(LSK.Packmenge AS float), 0) * CAST(LSK.Packmenge AS int) - LSK.Angefordert) / CONVERT(numeric(7, 2), LSK.Angefordert), N'P2', N'de-AT') AS [Abweichung %], */
  LSK.Packzettelnummer AS Packzettel,
  LSK.Lieferdatum
FROM #TmpLsKontrolle888h AS LSK
JOIN Mitarbei AS Betreuer ON LSK.BetreuerID = Betreuer.ID
JOIN Mitarbei AS Vertrieb ON LSK.VertreterID = Vertrieb.ID
JOIN Mitarbei AS Kundenservice ON LSK.ServiceID = Kundenservice.ID
CROSS APPLY dbo.funcGetNextVsaTouren(LSK.VsaID, -1, CAST(GETDATE() AS date), 0, 1, 0, 1, 1, 1, 0, 0) AS NextTour
WHERE LSK.Lieferdatum = NextTour.NextDate
  AND LSK.ServiceID IN ($2$)
ORDER BY LSK.KdNr, LSK.VsaStichwort, Packzettel;