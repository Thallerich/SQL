/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: PrepareData                                                                                                     ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #Result;
DROP TABLE IF EXISTS #Firma;
DROP TABLE IF EXISTS #KdGf;
DROP TABLE IF EXISTS #Vertriebszone;

CREATE TABLE #Result (
  Firma char(4),
  Geschäftsbereich nchar(5),
  Vertriebszone nvarchar(15),
  Hauptstandort nvarchar(60),
  Holding nvarchar(10),
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
  noFaktReason int,
  AlterWochen int,
  AnzahlWäschen int,
  Schrottgrund nvarchar(60)
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
  INSERT INTO #Result (Firma, Geschäftsbereich, Vertriebszone, Hauptstandort, Holding, KdNr, Kunde, Barcode, ArtikelNr, Artikelbezeichnung, Ausdienst, Preis, PreisPotentiell, faktKZ, gutschrKZ, faktStatus, noFaktReason, AlterWochen, AnzahlWäschen, Schrottgrund)
  SELECT Firma.SuchCode AS Firma,
    KdGf.KurzBez AS Geschäftsbereich,
    [Zone].ZonenCode AS Vertriebszone,
    Standort.SuchCode + ISNULL(N'' - ('' + Standort.Bez + '')'', N'''') AS Hauptstandort,
    Holding.Holding,
    Kunden.KdNr,
    Kunden.SuchCode AS Kunde,
    EinzHist.Barcode,
    Artikel.ArtikelNr,
    Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
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
    TeilSoFa.OhneBerechGrund,
    TeilSoFa.AlterWochen AS [Alter in Wochen],
    TeilSoFa.AnzWaeschen AS [Anzahl Wäschen],
    WegGrund.WegGrundBez$LAN$ AS Schrottgrund
  FROM TeilSoFa
  JOIN EinzHist ON TeilSoFa.EinzHistID = EinzHist.ID
  JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN Vsa ON EinzHist.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN Firma ON Kunden.FirmaID = Firma.ID
  JOIN KdGf ON Kunden.KdGfID = KdGf.ID
  JOIN Holding ON Kunden.HoldingID = Holding.ID
  JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
  JOIN Standort ON StandBer.ProduktionID = Standort.ID
  JOIN WegGrund ON EinzHist.WegGrundID = WegGrund.ID
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

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: Details                                                                                                         ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Firma, Geschäftsbereich, Vertriebszone, Hauptstandort, Holding, KdNr, Kunde, Barcode, ArtikelNr, Artikelbezeichnung, Ausdienst AS [Woche Außerdienststellung], Preis, PreisPotentiell AS [potentieller Preis], AlterWochen AS [Alter in Wochen], AnzahlWäschen AS [Anzahl Wäschen], Schrottgrund, fakturiert =
    CASE
        WHEN faktStatus = 3 THEN N'verrechnet'
        WHEN faktStatus = 2 THEN N'wird noch verrechnet'
        WHEN faktStatus = 5 THEN N'gutgeschrieben'
        WHEN faktStatus = 4 THEN N'wird noch gutgeschrieben'
        WHEN faktStatus = 1 THEN N'Rechnungsposition gelöscht'
        WHEN faktStatus = 0 THEN N'keine Verrechnung vorgesehen'
        ELSE N'<<unbekannt>>'
      END,
  [Grund für ausgebliebene Berechnung] = 
    CASE
      WHEN faktStatus != 0 OR noFaktReason = 0  THEN NULL
      WHEN faktStatus = 0 AND noFaktReason = 1  THEN N'im RW-Kontingent inkludiert'
      WHEN faktStatus = 0 AND noFaktReason = 2  THEN N'vertraglich nicht vorgesehen'
      WHEN faktStatus = 0 AND noFaktReason = 3  THEN N'Kunden-Austausch-Regel nicht erfüllt'
      WHEN faktStatus = 0 AND noFaktReason = 4  THEN N'frühzeitiger Größentausch kostenlos'
      WHEN faktStatus = 0 AND noFaktReason = 5  THEN N'Restwert ist null'
      WHEN faktStatus = 0 AND noFaktReason = 6  THEN N'Restwert unter Minimum'
      WHEN faktStatus = 0 AND noFaktReason = 7  THEN N'Pool-Teil'
      WHEN faktStatus = 0 AND noFaktReason = 8  THEN N'Benutzer hat Restwert-Faktura verneint'
      WHEN faktStatus = 0 AND noFaktReason = 9  THEN N'Restwert-Berechnung nicht zutreffend'
      WHEN faktStatus = 0 AND noFaktReason = 10 THEN N'Verschrottet mit Grund ohne Restwert-Berechnung'
      WHEN faktStatus = 0 AND noFaktReason = 11 THEN N'Eigentum sieht keine Restwert-Berechnung vor'
      WHEN faktStatus = 0 AND noFaktReason = 12 THEN N'Teil bereits für Restwert-Berechnung vorgesehen'
      WHEN faktStatus = 0 AND noFaktReason = 13 THEN N'Teil wurde schon als Kaufware ausgegeben'
      WHEN faktStatus = 0 AND noFaktReason = 14 THEN N'Restwert-Berechnung nachträglich abgebrochen'
      ELSE N'<<unbekannt>>'
    END
FROM (
  SELECT Firma, Geschäftsbereich, Vertriebszone, Hauptstandort, Holding, KdNr, Kunde, Barcode, ArtikelNr, Artikelbezeichnung, Ausdienst, MAX(Preis) AS Preis, PreisPotentiell, AlterWochen, AnzahlWäschen, Schrottgrund, MAX(faktStatus) AS faktStatus, MAX(noFaktReason) AS noFaktReason
  FROM #Result
  GROUP BY Firma, Geschäftsbereich, Vertriebszone, Hauptstandort, Holding, KdNr, Kunde, Barcode, ArtikelNr, Artikelbezeichnung, Ausdienst, PreisPotentiell, AlterWochen, AnzahlWäschen, Schrottgrund
) AS x;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: Summen                                                                                                          ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Hauptstandort,
  Geschäftsbereich,
  Vertriebszone,
  Holding,
  Kunde + N' (' + CAST(KdNr AS nvarchar) + N')' AS Kunde,
  SUM(IIF(AlterWochen <= 104, 1, 0)) AS [Teile gesamt (<= 104 Wochen)],
  SUM(IIF(AlterWochen <= 104 AND faktKZ = 1, 1, 0)) AS [Teile fakturiert (<= 104 Wochen)],
  SUM(IIF(AlterWochen <= 104 AND faktKZ = 1 AND gutschrKZ = 1, 1, 0)) AS [Teile gutgeschrieben (<= 104 Wochen)],
  SUM(IIF(AlterWochen <= 104 AND faktKZ = 0, 1, 0)) AS [Teile nicht fakturiert (<= 104 Wochen)],
  SUM(IIF(AlterWochen <= 104, PreisPotentiell, 0)) AS [Summe potentiell (<= 104 Wochen)],
  SUM(IIF(AlterWochen <= 104 AND faktKZ = 1, Preis, 0)) AS [Summe fakturiert (<= 104 Wochen)],
  SUM(IIF(AlterWochen <= 104 AND faktKZ = 1 AND gutschrKZ = 1, Preis, 0)) AS [Summe gutgeschrieben (<= 104 Wochen)],
  SUM(IIF(AlterWochen <= 104 AND faktKZ = 0, PreisPotentiell, 0)) AS [Summe nicht fakturiert (<= 104 Wochen)],
  ROUND(CAST(SUM(IIF(AlterWochen <= 104 AND faktKZ = 0, PreisPotentiell, 0)) AS float) / CAST(IIF(SUM(IIF(AlterWochen <= 104, PreisPotentiell, 0)) = 0, 1, SUM(IIF(AlterWochen <= 104, PreisPotentiell, 0))) AS float) * 100, 2) AS [Anteil (%) nicht fakturiert (<= 104 Wochen)],
  SUM(IIF(AlterWochen > 104, 1, 0)) AS [Teile gesamt (> 104 Wochen)],
  SUM(IIF(AlterWochen > 104 AND faktKZ = 1, 1, 0)) AS [Teile fakturiert (> 104 Wochen)],
  SUM(IIF(AlterWochen > 104 AND faktKZ = 1 AND gutschrKZ = 1, 1, 0)) AS [Teile gutgeschrieben (> 104 Wochen)],
  SUM(IIF(AlterWochen > 104 AND faktKZ = 0, 1, 0)) AS [Teile nicht fakturiert (> 104 Wochen)],
  SUM(IIF(AlterWochen > 104, PreisPotentiell, 0)) AS [Summe potentiell (> 104 Wochen)],
  SUM(IIF(AlterWochen > 104 AND faktKZ = 1, Preis, 0)) AS [Summe fakturiert (> 104 Wochen)],
  SUM(IIF(AlterWochen > 104 AND faktKZ = 1 AND gutschrKZ = 1, Preis, 0)) AS [Summe gutgeschrieben (> 104 Wochen)],
  SUM(IIF(AlterWochen > 104 AND faktKZ = 0, PreisPotentiell, 0)) AS [Summe nicht fakturiert (> 104 Wochen)],
  ROUND(CAST(SUM(IIF(AlterWochen > 104 AND faktKZ = 0, PreisPotentiell, 0)) AS float) / CAST(IIF(SUM(IIF(AlterWochen > 104, PreisPotentiell, 0)) = 0, 1, SUM(IIF(AlterWochen > 104, PreisPotentiell, 0))) AS float) * 100, 2) AS [Anteil (%) nicht fakturiert (> 104 Wochen)]

FROM (
  SELECT Firma, Geschäftsbereich, Vertriebszone, Hauptstandort, Holding, KdNr, Kunde, Barcode, Ausdienst, MAX(Preis) AS Preis, PreisPotentiell, MAX(faktKZ) AS faktKZ, MAX(gutschrKZ) AS gutschrKZ, AlterWochen, AnzahlWäschen
  FROM #Result
  GROUP BY Firma, Geschäftsbereich, Vertriebszone, Hauptstandort, Holding, KdNr, Kunde, Barcode, Ausdienst, PreisPotentiell, AlterWochen, AnzahlWäschen
) AS x
GROUP BY Hauptstandort, Geschäftsbereich, Vertriebszone, Holding, Kunde + N' (' + CAST(KdNr AS nvarchar) + N')';