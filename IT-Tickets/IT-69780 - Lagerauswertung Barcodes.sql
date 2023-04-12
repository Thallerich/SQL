DROP TABLE IF EXISTS #ReportingStandort;

GO

CREATE TABLE #ReportingStandort (
  StandortID int NOT NULL PRIMARY KEY CLUSTERED,
  SuchCode nchar(15) COLLATE Latin1_General_CS_AS
);

GO

INSERT INTO #ReportingStandort (StandortID, SuchCode)
SELECT Standort.ID, Standort.SuchCode
FROM Standort
WHERE Standort.SuchCode LIKE N'WOL_'
  AND Standort.SuchCode != N'WOLI'

GO

DROP TABLE IF EXISTS #Umlauf;

GO

CREATE TABLE #Umlauf (
  ArtGroeID int NOT NULL,
  ArtikelID int NOT NULL,
  ProduktionID int NOT NULL,
  Umlaufmenge int NOT NULL DEFAULT 0
);

ALTER TABLE #Umlauf ADD PRIMARY KEY CLUSTERED (ArtGroeID, ArtikelID, ProduktionID);

GO

DECLARE @CurrentWeek nchar(7) = (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat);

INSERT INTO #Umlauf (ArtGroeID, ArtikelID, ProduktionID, Umlaufmenge)
SELECT ArtGroeID, ArtikelID, ProduktionID, SUM(Umlauf) AS Umlaufmenge
FROM (
  SELECT VsaLeas.VsaID, - 1 AS TraegerID, VsaLeas.KdArtiID, COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, SUM(VsaLeas.Menge) AS Umlauf, StandBer.ProduktionID
  FROM VsaLeas
  JOIN Vsa ON VsaLeas.VsaID = Vsa.ID
  JOIN KdArti ON VsaLeas.KdArtiID = KdArti.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
  LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID AND ArtGroe.Groesse = N'-'
  WHERE @CurrentWeek BETWEEN ISNULL(VsaLeas.Indienst, N'1980/01') AND ISNULL(VsaLeas.Ausdienst, N'2099/52')
  GROUP BY VsaLeas.VsaID, VsaLeas.KdArtiID, COALESCE(ArtGroe.ID, -1), KdArti.ArtikelID, StandBer.ProduktionID

  UNION ALL

  SELECT VsaAnf.VsaID, - 1 AS TraegerID, VsaAnf.KdArtiID, COALESCE(IIF(VsaAnf.ArtGroeID < 0, NULL, VsaAnf.ArtGroeID), ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, SUM(VsaAnf.Bestand) AS Umlauf, StandBer.ProduktionID
  FROM VsaAnf
  JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
  JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
  LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID AND ArtGroe.Groesse = N'-'
  WHERE VsaAnf.Bestand != 0
    AND VsaAnf.[Status] = N'A'
  GROUP BY VsaAnf.VsaID, VsaAnf.KdArtiID, COALESCE(IIF(VsaAnf.ArtGroeID < 0, NULL, VsaAnf.ArtGroeID), ArtGroe.ID, -1), KdArti.ArtikelID, StandBer.ProduktionID

  UNION ALL

  SELECT Strumpf.VsaID, - 1 AS TraegerID, Strumpf.KdArtiID, COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, COUNT(Strumpf.ID) AS Umlauf, StandBer.ProduktionID
  FROM Strumpf
  JOIN KdArti ON Strumpf.KdArtiID = KdArti.ID
  JOIN Vsa ON Strumpf.VsaID = Vsa.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
  LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID AND ArtGroe.Groesse = N'-'
  WHERE Strumpf.[Status] != N'X'
    AND ISNULL(Strumpf.Indienst, N'1980/01') >= @CurrentWeek
    AND Strumpf.WegGrundID < 0
  GROUP BY Strumpf.VsaID, Strumpf.KdArtiID, COALESCE(ArtGroe.ID, -1), KdArti.ArtikelID, StandBer.ProduktionID
  
  UNION ALL

  SELECT Traeger.VsaID, TraeArti.TraegerID, TraeArti.KdArtiID, TraeArti.ArtGroeID, KdArti.ArtikelID, TraeArti.Menge AS Umlauf, StandBer.ProduktionID
  FROM TraeArti
  JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
  WHERE @CurrentWeek BETWEEN ISNULL(Traeger.Indienst, N'1980/01') AND ISNULL(Traeger.Ausdienst, N'2099/52')

  UNION ALL

  SELECT Traeger.VsaID, TraeArti.TraegerID, KdArti.ID AS KdArtiID, COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, TraeArti.Menge AS Umlauf, StandBer.ProduktionID
  FROM TraeArti
  JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  JOIN KdArAppl ON TraeArti.KdArtiID = KdArAppl.KdArtiID
  JOIN KdArti ON KdArAppl.ApplKdArtiID = KdArti.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
  LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID
  WHERE @CurrentWeek BETWEEN ISNULL(Traeger.Indienst, N'1980/01') AND ISNULL(Traeger.Ausdienst, N'2099/52')
    AND KdArAppl.ArtiTypeID = 3  --Emblem

  UNION ALL

  SELECT Traeger.VsaID, TraeArti.TraegerID, KdArti.ID AS KdArtiID, COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, TraeArti.Menge AS Umlauf, StandBer.ProduktionID
  FROM TraeArti
  JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  JOIN KdArAppl ON TraeArti.KdArtiID = KdArAppl.KdArtiID
  JOIN KdArti ON KdArAppl.ApplKdArtiID = KdArti.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
  LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID
  WHERE @CurrentWeek BETWEEN ISNULL(Traeger.Indienst, N'1980/01') AND ISNULL(Traeger.Ausdienst, N'2099/52')
    AND KdArAppl.ArtiTypeID = 2 --Namenschild
) AS x
GROUP BY ArtGroeID, ArtikelID, ProduktionID;

GO

DROP TABLE IF EXISTS #PivotSource;

GO

WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZHIST'
)
SELECT EinzHist.Barcode, Teilestatus.StatusBez AS [aktueller Status], Lagerart.LagerartBez AS Lagerart, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, IIF(Kunden.KdNr = 0, NULL, Kunden.KdNr) AS [Letzte KdNr], Kunden.SuchCode AS [Letzter Kunde], ISNULL(#Umlauf.Umlaufmenge, 0) AS Umlaufmenge, CAST(EinzHist.EinzHistVon AS date) AS [eingelagert seit], CAST(Bestand.GleitPreis AS float) AS Wert, EinzTeil.RuecklaufG AS Waschzyklen, Standort.SuchCode AS Produktion
INTO #PivotSource
FROM EinzHist
JOIN EinzTeil ON EinzHist.EinzTeilID = EinzTeil.ID
JOIN Kunden ON EinzHist.KundenID = Kunden.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Lagerart ON EinzHist.LagerArtID = Lagerart.ID
JOIN Bestand ON Bestand.ArtGroeID = ArtGroe.ID AND Bestand.LagerArtID = EinzHist.LagerArtID
LEFT JOIN #Umlauf ON EinzHist.ArtGroeID = #Umlauf.ArtGroeID
LEFT JOIN Standort ON #Umlauf.ProduktionID = Standort.ID
JOIN Teilestatus ON EinzHist.[Status] = Teilestatus.[Status]
WHERE EinzHist.EinzHistTyp = 2
  AND EinzHist.IsCurrEinzHist = 1
  AND EinzHist.[Status] IN (N'X', N'XE', N'XI')
  AND Lagerart.LagerID IN (SELECT StandortID FROM #ReportingStandort);

GO

DECLARE @pivotcols nvarchar(max), @pivotcolshead nvarchar(max), @pivotsql nvarchar(max);

SET @pivotcols = STUFF((SELECT DISTINCT N', [' + Produktion + N']' FROM #PivotSource WHERE Produktion IN (SELECT SuchCode FROM #ReportingStandort) ORDER BY 1 FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 1, '');

SET @pivotcolshead = STUFF((SELECT DISTINCT N', ISNULL([' + #PivotSource.Produktion + N'], 0) AS [Umlaufmenge ' + Standort.Bez + N']' FROM #PivotSource, Standort WHERE #PivotSource.Produktion = Standort.SuchCode AND #PivotSource.Produktion IN (SELECT SuchCode FROM #ReportingStandort) ORDER BY 1 FOR XML PATH(''), TYPE).value('.', N'nvarchar(max)'), 1, 1, '');

SET @pivotsql = N'
  SELECT Barcode, [aktueller Status], Lagerart, ArtikelNr, Artikelbezeichnung, Größe, [Letzte KdNr], [Letzter Kunde], ' + @pivotcolshead + N', [eingelagert seit], Wert, Waschzyklen
  FROM #PivotSource
  PIVOT (SUM(Umlaufmenge) FOR Produktion IN (' + @pivotcols + N')) AS p;';

EXEC sp_executesql @pivotsql;

GO