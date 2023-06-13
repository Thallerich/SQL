DECLARE @yearweek nchar(7) = $woche;
DECLARE @kundenid int = $kundenID;
DECLARE @webuserid int = $webuserID;
DECLARE @pivotcolumns nvarchar(max), @pivottotal nvarchar(max), @sqltext nvarchar(max);

DROP TABLE IF EXISTS #ReportWeek;

CREATE TABLE #ReportWeek (
  Woche nchar(7) COLLATE Latin1_General_CS_AS
);

SET @sqltext = N'
INSERT INTO #ReportWeek (Woche)
SELECT TOP 5 Week.Woche
FROM [Week]
WHERE Week.Woche <= @yearweek
ORDER BY Week.Woche DESC;
';

EXEC sp_executesql @sqltext, N'@yearweek nchar(7)', @yearweek;

SELECT @pivotcolumns = COALESCE(@pivotcolumns + ', ','') + QUOTENAME(#ReportWeek.Woche)
FROM #ReportWeek
ORDER BY #ReportWeek.Woche ASC;

SELECT @pivottotal = COALESCE(@pivottotal + ' + ISNULL(','ISNULL(') + QUOTENAME(#ReportWeek.Woche) + N', 0)'
FROM #ReportWeek
ORDER BY #ReportWeek.Woche ASC;

SET @sqltext = N'
SELECT Holding, KdNr, Kunde, ArtikelNr, Artikelbezeichnung, ' + @pivotcolumns + N', ' + @pivottotal + N' AS Gesamt, (' + @pivottotal + N') / 5 AS Durchschnitt
FROM (
  SELECT Holding.Holding, Kunden.KdNr, Kunden.Suchcode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Wochen.Woche, SUM(TraeArch.Menge) AS Menge
  FROM TraeArch
  JOIN Wochen ON TraeArch.WochenID = Wochen.ID
  JOIN Vsa ON TraeArch.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN Holding ON Kunden.HoldingID = Holding.ID
  JOIN TraeArti ON TraeArch.TraeArtiID = TraeArti.ID
  JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  WHERE Wochen.Woche IN (SELECT Woche FROM #ReportWeek)
    AND TraeArch.ApplKdArtiID = -1
    AND Kunden.ID = @kundenid
    AND Vsa.ID IN (
      SELECT Vsa.ID
      FROM Vsa
      JOIN WebUser ON WebUser.KundenID = Vsa.KundenID
      LEFT JOIN WebUVsa ON WebUVsa.WebUserID = WebUser.ID
      WHERE WebUser.ID = @webuserid
        AND (WebUVsa.ID IS NULL OR WebUVsa.VsaID = Vsa.ID)
    )
    AND TraeArch.AbteilID IN (
      SELECT WebUAbt.AbteilID
      FROM WebUAbt
      WHERE WebUAbt.WebUserID = @webuserid
    )
  GROUP BY Holding.Holding, Kunden.KdNr, Kunden.Suchcode, Artikel.ArtikelNr, Artikel.ArtikelBez, Wochen.Woche
) pivotdata
PIVOT (
  SUM(pivotdata.Menge)
  FOR pivotdata.Woche IN (' + @pivotcolumns + N')
) AS piv;
';

EXEC sp_executesql @sqltext, N'@kundenid int, @webuserid int', @kundenid, @webuserid;