DROP TABLE IF EXISTS #TmpBaxt24Months;
GO

CREATE TABLE #TmpBaxt24Months (
  ArtikelNr nvarchar(15) COLLATE Latin1_General_CS_AS,
  Artikelbezeichnung nvarchar(60) COLLATE Latin1_General_CS_AS,
  Woche nchar(7) COLLATE Latin1_General_CS_AS,
  Menge int
);

GO

INSERT INTO #TmpBaxt24Months (ArtikelNr, Artikelbezeichnung, Woche, Menge)
SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Wochen.Woche, SUM(AbtKdArW.Menge) AS Menge
FROM AbtKdArW
JOIN Abteil ON AbtKdArW.AbteilID = Abteil.ID
JOIN Kunden ON Abteil.KundenID = Kunden.ID
JOIN KdArti ON AbtKdArW.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN LiefArt ON KdArti.LiefArtID = LiefArt.ID
JOIN Wochen ON AbtKdArW.WochenID = Wochen.ID
JOIN Week ON Wochen.Woche = Week.Woche
WHERE Week.VonDat > DATEADD(month, -24, GETDATE())
  AND Kunden.KdNr = 10002771
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez, Wochen.Woche;

GO

DECLARE @pivotcols nvarchar(max);
DECLARE @pivotsql nvarchar(max);

SET @pivotcols = STUFF((SELECT DISTINCT ', [' + Woche + ']' FROM #TmpBaxt24Months ORDER BY 1 FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,1,'');
SET @pivotsql = N'SELECT ArtikelNr, Artikelbezeichnung, ' + @pivotcols + ' FROM #TmpBaxt24Months AS Pivotdata PIVOT (SUM(Menge) FOR Woche IN (' + @pivotcols + ')) AS p;';

EXEC sp_executesql @pivotsql;

GO

DROP TABLE #TmpBaxt24Months;
GO