DROP TABLE IF EXISTS #Result;
DROP TABLE IF EXISTS #Firma;
DROP TABLE IF EXISTS #KdGf;
DROP TABLE IF EXISTS #Vertriebszone;

CREATE TABLE #Result (
  Firma char(4),
  Geschäftsbereich nchar(5),
  Vertriebszone nvarchar(15),
  Hauptstandort nvarchar(60),
  KdNr int,
  Kunde nvarchar(20),
  Barcode nvarchar(33),
  ArtikelNr nvarchar(15),
  Artikelbezeichnung nvarchar(60),
  Ausdienst char(7),
  Preis money,
  PreisPotentiell money,
  faktKZ tinyint,
  gutschrKZ tinyint,
  faktStatus tinyint,
  AlterWochen int,
  AnzahlWäschen int
);

CREATE TABLE #Firma (
  FirmaID int
);

CREATE TABLE #KdGf (
  KdGfID int
);

CREATE TABLE #Vertriebszone (
  VertriebszoneID int
);

DECLARE @from date = $STARTDATE$, @to date = $ENDDATE$;
DECLARE @onlybk bit = $2$;
DECLARE @sqltext nvarchar(max);

INSERT INTO #Firma (FirmaID)
SELECT Firma.ID
FROM Firma
WHERE Firma.ID IN ($3$);

INSERT INTO #KdGf (KdGfID)
SELECT KdGf.ID
FROM KdGf
WHERE KdGf.ID IN ($4$);

INSERT INTO #Vertriebszone (VertriebszoneID)
SELECT [Zone].ID
FROM [Zone]
WHERE [Zone].ID IN ($5$);

SET @sqltext = N'
  INSERT INTO #Result (Firma, Geschäftsbereich, Vertriebszone, Hauptstandort, KdNr, Kunde, Barcode, ArtikelNr, Artikelbezeichnung, Ausdienst, Preis, PreisPotentiell, faktKZ, gutschrKZ, faktStatus, AlterWochen, AnzahlWäschen)
  SELECT Firma.SuchCode AS Firma,
    KdGf.KurzBez AS Geschäftsbereich,
    [Zone].ZonenCode AS Vertriebszone,
    Standort.SuchCode + ISNULL(N'' - ('' + Standort.Bez + '')'', N'''') AS Hauptstandort,
    Kunden.KdNr,
    Kunden.SuchCode AS Kunde,
    EinzHist.Barcode,
    Artikel.ArtikelNr,
    Artikel.ArtikelBez,
    EinzHist.Ausdienst,
    IIF(TeilSoFa.OhneBerechGrund > 0, 0, TeilSoFa.EPreis) AS Preis,
    TeilSoFa.EPreis AS [potentieller Preis],
    CAST(IIF(TeilSoFa.RechPoID > 0 OR TeilSoFa.Status = N''L'', 1, 0) AS tinyint) AS faktKZ,
    CAST(IIF(TeilSoFa.RechPoGutschriftID > 0 OR TeilSoFa.Status = N''T'', 1, 0) AS tinyint) AS gutschrKZ,
    faktStatus =
    CASE
      WHEN TeilSoFa.RechPoID > 0 AND TeilSoFa.RechPoGutschriftID < 0 THEN 3
      WHEN TeilSoFa.RechPoID < 0 AND TeilSoFa.[Status] = N''L'' THEN 2
      WHEN TeilSoFa.RechPoID > 0 AND TeilSoFa.RechPoGutschriftID > 0 THEN 5
      WHEN TeilSoFA.RechPoID > 0 AND TeilSoFa.RechPoGutschriftID < 0 AND TeilSoFa.[Status] = N''T'' THEN 4
      WHEN TeilSoFa.RechPoID < 0 AND TeilSoFa.[Status] = N''P'' THEN 1
      WHEN TeilSoFa.RechPoID < 0 AND TeilSoFa.[Status] = N''D'' THEN 0
      ELSE 255
    END,
    TeilSoFa.AlterWochen AS [Alter in Wochen],
    TeilSoFa.AnzWaeschen AS [Anzahl Wäschen]
  FROM TeilSoFa
  JOIN EinzHist ON TeilSoFa.EinzHistID = EinzHist.ID
  JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
  JOIN Kunden ON EinzHist.KundenID = Kunden.ID
  JOIN Firma ON Kunden.FirmaID = Firma.ID
  JOIN KdGf ON Kunden.KdGfID = KdGf.ID
  JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
  JOIN Standort ON Kunden.StandortID = Standort.ID
  WHERE TeilSoFa.Zeitpunkt BETWEEN CAST(@from AS datetime2) AND CAST(@to AS datetime2)
    AND Firma.ID IN (SELECT #Firma.FirmaID FROM #Firma)
    AND KdGf.ID IN (SELECT #KdGf.KdGfID FROM #KdGf)
    AND [Zone].ID IN (SELECT #Vertriebszone.VertriebszoneID FROM #Vertriebszone)
    AND TeilSoFa.SoFaArt = N''R''
    AND (EinzHist.Status = N''Y'' OR (EinzHist.Status = N''S'' AND EinzHist.WegGrundID > 0))
    AND Kunden.KdNr NOT IN (10005396, 100151)
';

IF @onlybk = 1
  SET @sqltext += N' AND EinzHist.PoolFkt = 0';

SET @sqltext += N';';

EXEC sp_executesql @sqltext, N'@from date, @to date', @from, @to;

GO

SELECT Firma, Geschäftsbereich, Vertriebszone, Hauptstandort, KdNr, Kunde, Barcode, ArtikelNr, Artikelbezeichnung, Ausdienst AS [Woche Außerdienststellung], Preis, PreisPotentiell AS [potentieller Preis], AlterWochen AS [Alter in Wochen], AnzahlWäschen AS [Anzahl Wäschen], fakturiert =
    CASE
        WHEN faktStatus = 3 THEN N'verrechnet'
        WHEN faktStatus = 2 THEN N'wird noch verrechnet'
        WHEN faktStatus = 5 THEN N'gutgeschrieben'
        WHEN faktStatus = 4 THEN N'wird noch gutgeschrieben'
        WHEN faktStatus = 1 THEN N'Rechnungsposition gelöscht'
        WHEN faktStatus = 0 THEN N'keine Verrechnung vorgesehen'
        ELSE N'<<unbekannt>>'
      END
FROM (
  SELECT Firma, Geschäftsbereich, Vertriebszone, Hauptstandort, KdNr, Kunde, Barcode, ArtikelNr, Artikelbezeichnung, Ausdienst, MAX(Preis) AS Preis, PreisPotentiell, AlterWochen, AnzahlWäschen, MAX(faktStatus) AS faktStatus
  FROM #Result
  GROUP BY Firma, Geschäftsbereich, Vertriebszone, Hauptstandort, KdNr, Kunde, Barcode, ArtikelNr, Artikelbezeichnung, Ausdienst, PreisPotentiell, AlterWochen, AnzahlWäschen
) AS x;

GO

SELECT Hauptstandort,
  Geschäftsbereich,
  Vertriebszone,
  Kunde + N' (' + CAST(KdNr AS nvarchar) + N')' AS Kunde,
  SUM(IIF(AlterWochen <= 104, 1, 0)) AS [Teile gesamt (<= 104 Wochen)],
  SUM(IIF(AlterWochen <= 104 AND faktKZ = 1, 1, 0)) AS [Teile fakturiert (<= 104 Wochen)],
  SUM(IIF(AlterWochen <= 104 AND faktKZ = 1 AND gutschrKZ = 1, 1, 0)) AS [Teile gutgeschrieben (<= 104 Wochen)],
  SUM(IIF(AlterWochen <= 104 AND faktKZ = 0, 1, 0)) AS [Teile nicht fakturiert (<= 104 Wochen)],
  SUM(IIF(AlterWochen <= 104, PreisPotentiell, 0)) AS [Summe potentiell (<= 104 Wochen)],
  SUM(IIF(AlterWochen <= 104 AND faktKZ = 1, Preis, 0)) AS [Summe fakturiert (<= 104 Wochen)],
  SUM(IIF(AlterWochen <= 104 AND faktKZ = 1 AND gutschrKZ = 1, Preis, 0)) AS [Summe gutgeschrieben (<= 104 Wochen)],
  SUM(IIF(AlterWochen <= 104 AND faktKZ = 0, PreisPotentiell, 0)) AS [Summe nicht fakturiert (<= 104 Wochen)],
  SUM(IIF(AlterWochen > 104, 1, 0)) AS [Teile gesamt (> 104 Wochen)],
  SUM(IIF(AlterWochen > 104 AND faktKZ = 1, 1, 0)) AS [Teile fakturiert (> 104 Wochen)],
  SUM(IIF(AlterWochen > 104 AND faktKZ = 1 AND gutschrKZ = 1, 1, 0)) AS [Teile gutgeschrieben (> 104 Wochen)],
  SUM(IIF(AlterWochen > 104 AND faktKZ = 0, 1, 0)) AS [Teile nicht fakturiert (> 104 Wochen)],
  SUM(IIF(AlterWochen > 104, PreisPotentiell, 0)) AS [Summe potentiell (> 104 Wochen)],
  SUM(IIF(AlterWochen > 104 AND faktKZ = 1, Preis, 0)) AS [Summe fakturiert (> 104 Wochen)],
  SUM(IIF(AlterWochen > 104 AND faktKZ = 1 AND gutschrKZ = 1, Preis, 0)) AS [Summe gutgeschrieben (> 104 Wochen)],
  SUM(IIF(AlterWochen > 104 AND faktKZ = 0, PreisPotentiell, 0)) AS [Summe nicht fakturiert (> 104 Wochen)]
FROM (
  SELECT Firma, Geschäftsbereich, Vertriebszone, Hauptstandort, KdNr, Kunde, Barcode, Ausdienst, MAX(Preis) AS Preis, PreisPotentiell, MAX(faktKZ) AS faktKZ, MAX(gutschrKZ) AS gutschrKZ, AlterWochen, AnzahlWäschen
  FROM #Result
  GROUP BY Firma, Geschäftsbereich, Vertriebszone, Hauptstandort, KdNr, Kunde, Barcode, Ausdienst, PreisPotentiell, AlterWochen, AnzahlWäschen
) AS x
GROUP BY Hauptstandort, Geschäftsbereich, Vertriebszone, Kunde + N' (' + CAST(KdNr AS nvarchar) + N')';

GO