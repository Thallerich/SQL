DROP TABLE IF EXISTS #Result;
DROP TABLE IF EXISTS #Firma;

CREATE TABLE #Result (
  Firma char(4),
  Geschäftsbereich nchar(5),
  Vertriebszone nvarchar(15),
  Hauptstandort nvarchar(60),
  KdNr int,
  Kunde nvarchar(20),
  Barcode nvarchar(33),
  Ausdienst char(7),
  Preis money,
  PreisPotentiell money,
  faktKZ bit,
  gutschrKZ bit,
  fakturiert nvarchar(30),
  keineBerechnungGrund nvarchar(75),
  AlterWochen int,
  AnzahlWäschen int
);

CREATE TABLE #Firma (
  FirmaID int
);

DECLARE @from date = $STARTDATE$, @to date = $ENDDATE$;
DECLARE @fromweek char(7), @toweek char(7);
DECLARE @sqltext nvarchar(max);

SELECT @fromweek = [Week].Woche FROM [Week] WHERE @from BETWEEN [Week].VonDat AND [Week].BisDat;
SELECT @toweek = [Week].Woche FROM [Week] WHERE @to BETWEEN [Week].VonDat AND [Week].BisDat;

INSERT INTO #Firma (FirmaID)
SELECT Firma.ID
FROM Firma
WHERE Firma.ID IN ($2$);

SET @sqltext = N'
  INSERT INTO #Result (Firma, Geschäftsbereich, Vertriebszone, Hauptstandort, KdNr, Kunde, Barcode, Ausdienst, Preis, PreisPotentiell, faktKZ, gutschrKZ, fakturiert, keineBerechnungGrund, AlterWochen, AnzahlWäschen)
  SELECT Firma.SuchCode AS Firma,
    KdGf.KurzBez AS Geschäftsbereich,
    [Zone].ZonenCode AS Vertriebszone,
    Standort.SuchCode + ISNULL(N'' - ('' + Standort.Bez + '')'', N'''') AS Hauptstandort,
    Kunden.KdNr,
    Kunden.SuchCode AS Kunde,
    EinzHist.Barcode,
    EinzHist.Ausdienst,
    IIF(TeilSoFa.OhneBerechGrund > 0, 0, TeilSoFa.EPreis) AS Preis,
    TeilSoFa.EPreis AS [potentieller Preis],
    CAST(IIF(TeilSoFa.RechPoID > 0 OR TeilSoFa.Status = N''L'', 1, 0) AS bit) AS faktKZ,
    CAST(IIF(TeilSoFa.RechPoGutschriftID > 0 OR TeilSoFa.Status = N''T'', 1, 0) AS bit) AS gutschrKZ,
    fakturiert = 
      CASE
        WHEN TeilSoFa.RechPoID > 0 AND TeilSoFa.RechPoGutschriftID < 0 THEN N''verrechnet''
        WHEN TeilSoFa.RechPoID < 0 AND TeilSoFa.[Status] = N''L'' THEN N''wird noch verrechnet''
        WHEN TeilSoFa.RechPoID > 0 AND TeilSoFa.RechPoGutschriftID > 0 THEN N''gutgeschrieben''
        WHEN TeilSoFA.RechPoID > 0 AND TeilSoFa.RechPoGutschriftID < 0 AND TeilSoFa.[Status] = N''T'' THEN N''wird noch gutgeschrieben''
        WHEN TeilSoFa.RechPoID < 0 AND TeilSoFa.[Status] = N''P'' THEN N''Rechnungsposition gelöscht''
        WHEN TeilSoFa.RechPoID < 0 AND TeilSoFa.[Status] = N''D'' THEN N''keine Verrechnung vorgesehen''
        ELSE N''<<unbekannt>>''
      END,
    [keine Berechnung weil] =
      CASE TeilSoFA.OhneBerechGrund
        WHEN 0 THEN NULL
        WHEN 1 THEN N''inklusive RW-Kontingent''
        WHEN 2 THEN N''vertraglich nicht vorgesehen''
        WHEN 3 THEN N''Kunden-Austausch-Regeln nicht erfüllt''
        WHEN 4 THEN N''frühzeitiger Größentausch kostenlos ''
        WHEN 5 THEN N''Restwert 0''
        WHEN 6 THEN N''Restwert unter Min.''
        WHEN 7 THEN N''Teil ist Pool-Teil''
        WHEN 8 THEN N''Benutzer hat Restwert-Faktura verneint''
        WHEN 9 THEN N''Restwert-Berechnung nicht zutreffend (Außerdienststellung ohne RW-Berech.)''
        WHEN 10 THEN N''Verschrottung mit Grund ohne RW-Berechnung''
        WHEN 11 THEN N''Eigentum sieht keine RW-Berech. vor''
        WHEN 12 THEN N''Teil schon für Restwert-Berechnung markiert''
        WHEN 13 THEN N''Teil wurde schon vorher als Kaufware ausgegeben''
        WHEN 14 THEN N''Berechnung nachträglich verhindert''
        ELSE N''<<unknown>>''
      END,
    TeilSoFa.AlterWochen AS [Alter in Wochen],
    TeilSoFa.AnzWaeschen AS [Anzahl Wäschen]
  FROM TeilSoFa
  JOIN EinzHist ON TeilSoFa.EinzHistID = EinzHist.ID
  JOIN Einsatz ON TeilSoFa.AusdienstGrund = Einsatz.EinsatzGrund
  JOIN Kunden ON EinzHist.KundenID = Kunden.ID
  JOIN Firma ON Kunden.FirmaID = Firma.ID
  JOIN KdGf ON Kunden.KdGfID = KdGf.ID
  JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
  JOIN Standort ON Kunden.StandortID = Standort.ID
  WHERE EinzHist.Ausdienst BETWEEN @fromweek AND @toweek
    AND Firma.ID IN (SELECT #Firma.FirmaID FROM #Firma)
    AND TeilSoFa.AusdienstGrund IN (N''A'', N''a'', N''E'', N''e'');
';

EXEC sp_executesql @sqltext, N'@fromweek char(7), @toweek char(7)', @fromweek, @toweek;

GO

SELECT Firma, Geschäftsbereich, Vertriebszone, Hauptstandort, KdNr, Kunde, Barcode, Ausdienst AS [Woche Außerdienststellung], Preis, PreisPotentiell AS [potentieller Preis], fakturiert, keineBerechnungGrund AS [keine Berechechnung weil], AlterWochen AS [Alter in Wochen], AnzahlWäschen AS [Anzahl Wäschen]
FROM #Result;

GO

SELECT Hauptstandort,
  SUM(IIF(AlterWochen <= 104, 1, 0)) AS [Teile gesamt (<= 104 Wochen)],
  SUM(IIF(AlterWochen <= 104 AND faktKZ = 1 AND gutschrKZ = 0, 1, 0)) AS [Teile fakturiert (<= 104 Wochen)],
  SUM(IIF(AlterWochen <= 104 AND faktKZ = 1 AND gutschrKZ = 1, 1, 0)) AS [Teile gutgeschrieben (<= 104 Wochen)],
  SUM(IIF(AlterWochen <= 104 AND faktKZ = 0, 1, 0)) AS [Teile nicht fakturiert (<= 104 Wochen)],
  SUM(IIF(AlterWochen <= 104, PreisPotentiell, 0)) AS [Summe potentiell (<= 104 Wochen)],
  SUM(IIF(AlterWochen <= 104 AND faktKZ = 1 AND gutschrKZ = 0, Preis, 0)) AS [Summe fakturiert (<= 104 Wochen)],
  SUM(IIF(AlterWochen <= 104 AND faktKZ = 1 AND gutschrKZ = 1, Preis, 0)) AS [Summe gutgeschrieben (<= 104 Wochen)],
  SUM(IIF(AlterWochen <= 104 AND faktKZ = 0, PreisPotentiell, 0)) AS [Summe nicht fakturiert (<= 104 Wochen)],
  SUM(IIF(AlterWochen > 104, 1, 0)) AS [Teile gesamt (> 104 Wochen)],
  SUM(IIF(AlterWochen > 104 AND faktKZ = 1 AND gutschrKZ = 0, 1, 0)) AS [Teile fakturiert (> 104 Wochen)],
  SUM(IIF(AlterWochen > 104 AND faktKZ = 1 AND gutschrKZ = 1, 1, 0)) AS [Teile gutgeschrieben (> 104 Wochen)],
  SUM(IIF(AlterWochen > 104 AND faktKZ = 0, 1, 0)) AS [Teile nicht fakturiert (> 104 Wochen)],
  SUM(IIF(AlterWochen > 104, PreisPotentiell, 0)) AS [Summe potentiell (> 104 Wochen)],
  SUM(IIF(AlterWochen > 104 AND faktKZ = 1 AND gutschrKZ = 0, Preis, 0)) AS [Summe fakturiert (> 104 Wochen)],
  SUM(IIF(AlterWochen > 104 AND faktKZ = 1 AND gutschrKZ = 1, Preis, 0)) AS [Summe gutgeschrieben (> 104 Wochen)],
  SUM(IIF(AlterWochen > 104 AND faktKZ = 0, PreisPotentiell, 0)) AS [Summe nicht fakturiert (> 104 Wochen)]
FROM #Result
GROUP BY Hauptstandort;

GO