DECLARE @RealLocation TABLE (
  LocationID int PRIMARY KEY NOT NULL
);

IF $2$ = 1
  INSERT INTO @RealLocation (LocationID)
  SELECT Standort.ID
  FROM Standort
  WHERE Standort.SuchCode LIKE N'WOE_';

IF $2$ = 2
  INSERT INTO @RealLocation (LocationID)
  SELECT Standort.ID
  FROM Standort
  WHERE Standort.SuchCode LIKE N'UKL_';

IF $2$ = 3
  INSERT INTO @RealLocation (LocationID)
  VALUES (5133);

DROP TABLE IF EXISTS #OPSchrott;

CREATE TABLE #OPSchrott (
  EinzTeilID int PRIMARY KEY NOT NULL,
  [Code] nvarchar(33) COLLATE Latin1_General_CS_AS,
  ArtikelID int NOT NULL,
  WegGrundID int NOT NULL,
  WegDatum date,
  VsaID int NOT NULL,
  Erstwoche nchar(7) COLLATE Latin1_General_CS_AS,
  RuecklaufG int NOT NULL,
  ProduktionID int NOT NULL
);

INSERT INTO #OPSchrott (EinzTeilID, [Code], ArtikelID, WegGrundID, WegDatum, VsaID, Erstwoche, RuecklaufG, ProduktionID)
SELECT EinzTeil.ID AS EinzTeilID, EinzTeil.Code, EinzTeil.ArtikelID, EinzTeil.WegGrundID, EinzTeil.WegDatum, EinzTeil.VsaID, EinzTeil.Erstwoche, EinzTeil.RuecklaufG, ProduktionID = ISNULL((
    SELECT TOP 1 COALESCE(IIF(ZielNr.ProduktionsID < 0, NULL, ZielNr.ProduktionsID), IIF(ArbPlatz.StandortID < 0, NULL, ArbPlatz.StandortID), IIF(Mitarbei.StandortID < 0, NULl, Mitarbei.StandortID), -1)
    FROM Scans
    JOIN ZielNr ON Scans.ZielNrID = ZielNr.ID
    JOIN ArbPlatz ON Scans.ArbPlatzID = ArbPlatz.ID
    JOIN Mitarbei ON Scans.AnlageUserID_ = Mitarbei.ID
    WHERE Scans.EinzTeilID = EinzTeil.ID
      AND Scans.ActionsID IN (7, 108)
    ORDER BY Scans.[DateTime] DESC
  ), -1)
FROM EinzTeil
WHERE EinzTeil.WegDatum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND EinzTeil.WegGrundID IN ($3$)
  AND EinzTeil.Status = N'Z';

SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, #OPSchrott.Code, WegGrund.WegGrundBez$LAN$ AS Schrottgrund, #OPSchrott.WegDatum AS Schrottdatum, ISNULL(Standort.SuchCode, N'<unbekannt>') AS [verschrottender Produktionsstandort], Kunden.KdNr AS [letzter Kunde], #OPSchrott.Erstwoche AS [Ersteinsatz-Woche], #OPSchrott.RuecklaufG AS [Anzahl Wäschen], Artikel.MaxWaschen AS [maximale Wäschen], Artikel.EKPreis AS Einkaufspreis, (Artikel.EKPreis/IIF(Artikel.MaxWaschen = 0, 1, Artikel.MaxWaschen)) * (Artikel.MaxWaschen - #OPSchrott.RuecklaufG) * IIF(Artikel.MaxWaschen = 0, 0, 1) AS Restwert
FROM #OPSchrott
JOIN Artikel ON #OPSchrott.ArtikelID = Artikel.ID
JOIN WegGrund ON #OPSchrott.WegGrundID = WegGrund.ID
JOIN Vsa ON #OPSchrott.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Standort ON #OPSchrott.ProduktionID = Standort.ID
WHERE #OPSchrott.ProduktionID IN (SELECT LocationID FROM @RealLocation)
  AND Artikel.BereichID = (SELECT ID FROM Bereich WHERE Bereich = N'ST')
ORDER BY Schrottdatum ASC;