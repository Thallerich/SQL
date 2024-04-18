DROP TABLE IF EXISTS #EinzHist;
GO

SELECT Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.VsaNr,
  Vsa.SuchCode AS [VSA-Stichwort],
  Vsa.Bez AS [VSA-Bezeichnung],
  Artikel.ArtikelNr,
  Artikel.ArtikelBez AS Artikelbezeichnung,
  ArtGroe.Groesse AS Größe,
  EinzHist.Barcode,
  EinzHist.Patchdatum,
  EinzHist.RuecklaufK AS [Waschzyklen aktueller Einsatz],
  EinzTeil.RuecklaufG AS [Waschzyklen gesamte Lebensdauer],
  EinzHist.ID AS EinzHistID
INTO #EinzHist
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
WHERE StandBer.ProduktionID = (SELECT Standort.ID FROM Standort WHERE Standort.SuchCode = N'WOL6')
  AND EinzHist.[Status] = N'Q'
  AND EinzHist.EinzHistTyp = 1
  AND Kunden.[Status] = N'A';

GO

SELECT #EinzHist.*,
  [Anzahl neu patchen] = (SELECT COUNT(Scans.ID) FROM Scans WHERE Scans.EinzHistID = #EinzHist.EinzHistID AND Scans.ActionsID = 23 AND Scans.[DateTime] > CAST(DATEADD(day, 1, #EinzHist.PatchDatum) AS datetime2))
FROM #EinzHist;

GO