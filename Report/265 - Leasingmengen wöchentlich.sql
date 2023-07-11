/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pro Kostenstelle und Artikel                                                                                              ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @sqltext nvarchar(max), @pivotcolumns nvarchar(max), @pivottotal nvarchar(max), @createcolumns nvarchar(max), @endlastweek date;
DECLARE @customerid int = $2$;

DROP TABLE IF EXISTS #ReportWeek;
DROP TABLE IF EXISTS #ResultSet265;

CREATE TABLE #ReportWeek (
  WeekNumber nchar(7) COLLATE Latin1_General_CS_AS
);

SELECT @endlastweek = CAST(DATEADD(day, -1 - (DATEPART(weekday, GETDATE()) + @@DATEFIRST - 2) % 7, GETDATE()) AS date)

INSERT INTO #ReportWeek (WeekNumber)
SELECT [Week].Woche
FROM [Week]
WHERE [Week].VonDat >= $STARTDATE$
  AND [Week].BisDat <= $ENDDATE$
  AND [Week].BisDat <= @endlastweek;

SELECT @pivotcolumns = COALESCE(@pivotcolumns + ', ','') + QUOTENAME(#ReportWeek.WeekNumber)
FROM #ReportWeek
ORDER BY #ReportWeek.WeekNumber ASC;

SELECT @pivottotal = COALESCE(@pivottotal + ' + ISNULL(','ISNULL(') + QUOTENAME(#ReportWeek.WeekNumber) + N', 0)'
FROM #ReportWeek
ORDER BY #ReportWeek.WeekNumber ASC;

SELECT @createcolumns = COALESCE(@createcolumns + ' int, ','') + QUOTENAME(#ReportWeek.WeekNumber)
FROM #ReportWeek
ORDER BY #ReportWeek.WeekNumber ASC;

SET @sqltext = N'
CREATE TABLE ##ResultSet265 (
  KdNr int,
  Kunde nvarchar(20) COLLATE Latin1_General_CS_AS,
  Kostenstelle nvarchar(20) COLLATE Latin1_General_CS_AS,
  Kostenstellenbezeichnung nvarchar(80) COLLATE Latin1_General_CS_AS,
  ArtikelNr nvarchar(15) COLLATE Latin1_General_CS_AS,
  Artikelbezeichnung nvarchar(60) COLLATE Latin1_General_CS_AS,
  ' + @createcolumns + N' int,
  Gesamt int
);
';

EXEC sp_executesql @sqltext;

SET @sqltext = N'
  INSERT INTO ##ResultSet265
  SELECT KdNr, Kunde, Kostenstelle, Kostenstellenbezeichnung, ArtikelNr, Artikelbezeichnung, ' + @pivotcolumns + N', ' + @pivottotal + N' AS Gesamt
  FROM (
    SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Wochen.Woche, SUM(TraeArch.Menge) AS Leasingmenge
    FROM TraeArch
    JOIN Wochen ON TraeArch.WochenID = Wochen.ID
    JOIN Kunden ON TraeArch.KundenID = Kunden.ID
    JOIN TraeArti ON TraeArch.TraeArtiID = TraeArti.ID
    JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
    JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
    JOIN Abteil ON TraeArch.AbteilID = Abteil.ID
    WHERE Wochen.Woche IN (SELECT WeekNumber FROM #ReportWeek)
      AND TraeArch.ApplKdArtiID = -1
      AND Kunden.ID = @customerid
    GROUP BY Kunden.KdNr, Kunden.Suchcode, Abteil.Abteilung, Abteil.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, Wochen.Woche
  ) pivotdata
  PIVOT (
    SUM(pivotdata.Leasingmenge)
    FOR pivotdata.Woche IN (' + @pivotcolumns + N')
  ) AS piv;
';

EXEC sp_executesql @sqltext, N'@customerid int', @customerid;

SELECT *
INTO #ResultSet265
FROM ##ResultSet265;

DROP TABLE ##ResultSet265;

SELECT *
FROM #ResultSet265;


/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pro VSA und Artikel                                                                                              ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @sqltext nvarchar(max), @pivotcolumns nvarchar(max), @pivottotal nvarchar(max), @createcolumns nvarchar(max), @endlastweek date;
DECLARE @customerid int = $2$;

DROP TABLE IF EXISTS #ReportWeek;
DROP TABLE IF EXISTS #ResultSet265;

CREATE TABLE #ReportWeek (
  WeekNumber nchar(7) COLLATE Latin1_General_CS_AS
);

SELECT @endlastweek = CAST(DATEADD(day, -1 - (DATEPART(weekday, GETDATE()) + @@DATEFIRST - 2) % 7, GETDATE()) AS date)

INSERT INTO #ReportWeek (WeekNumber)
SELECT [Week].Woche
FROM [Week]
WHERE [Week].VonDat >= $STARTDATE$
  AND [Week].BisDat <= $ENDDATE$
  AND [Week].BisDat <= @endlastweek;

SELECT @pivotcolumns = COALESCE(@pivotcolumns + ', ','') + QUOTENAME(#ReportWeek.WeekNumber)
FROM #ReportWeek
ORDER BY #ReportWeek.WeekNumber ASC;

SELECT @pivottotal = COALESCE(@pivottotal + ' + ISNULL(','ISNULL(') + QUOTENAME(#ReportWeek.WeekNumber) + N', 0)'
FROM #ReportWeek
ORDER BY #ReportWeek.WeekNumber ASC;

SELECT @createcolumns = COALESCE(@createcolumns + ' int, ','') + QUOTENAME(#ReportWeek.WeekNumber)
FROM #ReportWeek
ORDER BY #ReportWeek.WeekNumber ASC;

SET @sqltext = N'
CREATE TABLE ##ResultSet265 (
  KdNr int,
  Kunde nvarchar(20) COLLATE Latin1_General_CS_AS,
  VsaNr int,
  [VSA-Bezeichnung] nvarchar(40) COLLATE Latin1_General_CS_AS,
  ArtikelNr nvarchar(15) COLLATE Latin1_General_CS_AS,
  Artikelbezeichnung nvarchar(60) COLLATE Latin1_General_CS_AS,
  ' + @createcolumns + N' int,
  Gesamt int
);
';

EXEC sp_executesql @sqltext;

SET @sqltext = N'
  INSERT INTO ##ResultSet265
  SELECT KdNr, Kunde, VsaNr, [VSA-Bezeichnung], ArtikelNr, Artikelbezeichnung, ' + @pivotcolumns + N', ' + @pivottotal + N' AS Gesamt
  FROM (
    SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [VSA-Bezeichnung], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Wochen.Woche, SUM(TraeArch.Menge) AS Leasingmenge
    FROM TraeArch
    JOIN Wochen ON TraeArch.WochenID = Wochen.ID
    JOIN Vsa ON TraeArch.VsaID = Vsa.ID
    JOIN Kunden ON Vsa.KundenID = Kunden.ID
    JOIN TraeArti ON TraeArch.TraeArtiID = TraeArti.ID
    JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
    JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
    JOIN Abteil ON TraeArch.AbteilID = Abteil.ID
    WHERE Wochen.Woche IN (SELECT WeekNumber FROM #ReportWeek)
      AND TraeArch.ApplKdArtiID = -1
      AND Kunden.ID = @customerid
    GROUP BY Kunden.KdNr, Kunden.Suchcode, Vsa.VsaNr, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, Wochen.Woche
  ) pivotdata
  PIVOT (
    SUM(pivotdata.Leasingmenge)
    FOR pivotdata.Woche IN (' + @pivotcolumns + N')
  ) AS piv;
';

EXEC sp_executesql @sqltext, N'@customerid int', @customerid;

SELECT *
INTO #ResultSet265
FROM ##ResultSet265;

DROP TABLE ##ResultSet265;

SELECT *
FROM #ResultSet265;