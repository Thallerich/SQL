/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: Liefermenge                                                                                                     ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @von date = $STARTDATE$;
DECLARE @bis date = $ENDDATE$;

DROP TABLE IF EXISTS #EinzTeilProd;
DROP TABLE IF EXISTS #OPStats;
DROP TABLE IF EXISTS #OPDaten;
DROP TABLE IF EXISTS #LS;
DROP TABLE IF EXISTS #Standort;

CREATE TABLE #EinzTeilProd (
  EinzTeilID int PRIMARY KEY,
  ArtikelID int NOT NULL,
  LastScanID bigint DEFAULT -1
);

CREATE INDEX IX_TmpEinzTeilProd_LastScan ON #EinzTeilProd (LastScanID);

CREATE TABLE #OPStats (
  StandortID int NOT NULL,
  ArtikelID int NOT NULL,
  Liefermenge int NOT NULL DEFAULT 0,
  Schrottmenge int NOT NULL DEFAULT 0,
  NeuMenge int NOT NULL DEFAULT 0,
  InProd int NOT NULL DEFAULT 0
);

CREATE TABLE #OPDaten (
  StandortID int NOT NULL,
  OPEtiPoID int PRIMARY KEY CLUSTERED,
  ArtikelID int,
  EinzTeilID int,
  OPEinwegID int,
  Artikel1ID int,
  Artikel2ID int,
  LsMenge numeric(18,4),
  PackmengeSet int,
  Ersatzartikel bit
);
CREATE INDEX IX_TmpOPDaten_EinzTeilID ON #OPDaten (EinzTeilID);

CREATE TABLE #LS (
  LsPoID int PRIMARY KEY,
  StandortID int NOT NULL,
  Menge numeric(18,4) NOT NULL,
  KdArtiID int NOT NULL
);

CREATE TABLE #Standort (
  StandortID int,
  OPStandortID int
);

INSERT INTO #Standort (StandortID)
SELECT Standort.ID
FROM Standort
WHERE Standort.ID IN ($3$);

UPDATE #Standort SET OPStandortID = 
  CASE StandortID
    WHEN 2 THEN 2
    WHEN 4 THEN 2
    WHEN 4547 THEN 2
    WHEN 5005 THEN 2
    WHEN 5007 THEN 2
    WHEN 5010 THEN 2
    WHEN 5011 THEN 2
    WHEN 5001 THEN 5001
    WHEN 5000 THEN 5001
    WHEN 5212 THEN 5001
    WHEN 5213 THEN 5001
    WHEN 5214 THEN 5001
    WHEN 5133 THEN 5133
    ELSE -1
  END;

INSERT INTO #LS (LsPoID, StandortID, Menge, KdArtiID)
SELECT LsPo.ID, s.OPStandortID, LsPo.Menge, LsPo.KdArtiID
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN #Standort s ON LsPo.ProduktionID = s.StandortID
WHERE LsKo.Datum BETWEEN @von AND @bis
  AND LsKo.[Status] >= N'Q';

INSERT INTO #OPDaten (StandortID, OPEtiPoID, ArtikelID, EinzTeilID, OPEinwegID, Artikel1ID, Artikel2ID, LsMenge, PackmengeSet, Ersatzartikel)
SELECT #LS.StandortID, OPEtiPo.ID AS OPEtiPoID, OPEtiKo.ArtikelID, OPEtiPo.EinzTeilID, OPEtiPo.OPEinwegID, OPSets.Artikel1ID, OPSets.Artikel2ID, #LS.Menge AS LsMenge, OPSets.Menge AS PackmengeSet, OPEtiPo.Ersatzartikel
FROM OPEtiPo
JOIN OPEtiKo ON OPEtiPo.OPEtiKoID = OPEtiKo.ID
JOIN OPSets ON OPEtiPo.OPSetsID = OPSets.ID
JOIN #LS ON OPEtiKo.LsPoID = #LS.LsPoID;

INSERT INTO #OPStats (StandortID, ArtikelID, Liefermenge)
SELECT #OPDaten.StandortID, EinzTeil.ArtikelID, COUNT(#OPDaten.OPEtiPoID) AS Liefermenge
FROM #OPDaten
JOIN EinzTeil ON #OPDaten.EinzTeilID = EinzTeil.ID
WHERE #OPDaten.EinzTeilID > 0
  AND #OPDaten.OPEinwegID = -1
  AND NOT EXISTS (
    SELECT SiS.*
    FROM OPSets AS SiS
    WHERE Sis.ArtikelID = #OPDaten.Artikel1ID
  )
GROUP BY #OPDaten.StandortID, EinzTeil.ArtikelID;

MERGE INTO #OPStats AS OPStats
USING (
  SELECT #OPDaten.StandortID AS StandortID, OPEinweg.ArtikelID, COUNT(#OPDaten.OPEtiPoID) AS Liefermenge
  FROM #OPDaten
  JOIN Artikel SetArti ON #OPDaten.ArtikelID = SetArti.ID
  JOIN OPEinweg ON #OPDaten.OPEinwegID = OPEinweg.ID
  WHERE #OPDaten.EinzTeilID = -1
    AND #OPDaten.OPEinwegID > 0
    AND NOT EXISTS (
      SELECT SiS.*
      FROM OPSets AS SiS
      WHERE Sis.ArtikelID = #OPDaten.Artikel1ID
    )
  GROUP BY #OPDaten.StandortID, OPEinweg.ArtikelID
) AS NoScanLiefermenge (StandortID, ArtikelID, Liefermenge)
ON OPStats.ArtikelID = NoScanLiefermenge.ArtikelID AND OPStats.StandortID = NoScanLiefermenge.StandortID
WHEN MATCHED THEN
  UPDATE SET OPStats.Liefermenge = OPStats.Liefermenge + NoScanLiefermenge.Liefermenge
WHEN NOT MATCHED THEN
  INSERT (StandortID, ArtikelID, Liefermenge) VALUES (NoScanLiefermenge.StandortID, NoScanLiefermenge.ArtikelID, NoScanLiefermenge.Liefermenge);

MERGE INTO #OPStats AS OPStats
USING (
  SELECT #OPDaten.StandortID AS StandortID, #OPDaten.Artikel1ID AS ArtikelID, SUM(CAST(#OPDaten.LsMenge AS int) * (#OPDaten.PackmengeSet / SetArti.Packmenge)) AS Liefermenge
  FROM #OPDaten
  JOIN Artikel SetArti ON #OPDaten.ArtikelID = SetArti.ID
  WHERE #OPDaten.EinzTeilID = -1
    AND #OPDaten.OPEinwegID = -1
    AND #OPDaten.Ersatzartikel = 0
    AND NOT EXISTS (
      SELECT SiS.*
      FROM OPSets AS SiS
      WHERE Sis.ArtikelID = #OPDaten.Artikel1ID
    )
  GROUP BY #OPDaten.StandortID, #OPDaten.Artikel1ID
) AS NoScanLiefermenge (StandortID, ArtikelID, Liefermenge)
ON OPStats.ArtikelID = NoScanLiefermenge.ArtikelID AND OPStats.StandortID = NoScanLiefermenge.StandortID
WHEN MATCHED THEN
  UPDATE SET OPStats.Liefermenge = OPStats.Liefermenge + NoScanLiefermenge.Liefermenge
WHEN NOT MATCHED THEN
  INSERT (StandortID, ArtikelID, Liefermenge) VALUES (NoScanLiefermenge.StandortID, NoScanLiefermenge.ArtikelID, NoScanLiefermenge.Liefermenge);

MERGE INTO #OPStats AS OPStats
USING (
  SELECT #OPDaten.StandortID AS StandortID, #OPDaten.Artikel2ID AS ArtikelID, SUM(CAST(#OPDaten.LsMenge AS int) * (#OPDaten.PackmengeSet / SetArti.Packmenge)) AS Liefermenge
  FROM #OPDaten
  JOIN Artikel SetArti ON #OPDaten.ArtikelID = SetArti.ID
  WHERE #OPDaten.EinzTeilID = -1
    AND #OPDaten.OPEinwegID = -1
    AND #OPDaten.Ersatzartikel = 1
    AND NOT EXISTS (
      SELECT SiS.*
      FROM OPSets AS SiS
      WHERE Sis.ArtikelID = #OPDaten.Artikel1ID
    )
  GROUP BY #OPDaten.StandortID, #OPDaten.Artikel2ID
) AS NoScanLiefermenge (StandortID, ArtikelID, Liefermenge)
ON OPStats.ArtikelID = NoScanLiefermenge.ArtikelID AND OPStats.StandortID = NoScanLiefermenge.StandortID
WHEN MATCHED THEN
  UPDATE SET OPStats.Liefermenge = OPStats.Liefermenge + NoScanLiefermenge.Liefermenge
WHEN NOT MATCHED THEN
  INSERT (StandortID, ArtikelID, Liefermenge) VALUES (NoScanLiefermenge.StandortID, NoScanLiefermenge.ArtikelID, NoScanLiefermenge.Liefermenge);

MERGE INTO #OPStats AS OPStats
USING (
  SELECT #LS.StandortID AS StandortID, Artikel.ID AS ArtikelID, SUM(CAST(#LS.Menge AS int) * (OPSets.Menge / OPSetArtikel.Packmenge) * (SiS.Menge / SiSArtikel.Packmenge)) AS Liefermenge
  FROM #LS
  JOIN KdArti ON #LS.KdArtiID = KdArti.ID
  JOIN OPSets ON OPSets.ArtikelID = KdArti.ArtikelID
  JOIN OPSets AS SiS ON OPSets.Artikel1ID = SiS.ArtikelID
  JOIN Artikel ON SiS.Artikel1ID = Artikel.ID
  JOIN Artikel AS OPSetArtikel ON OPSets.ArtikelID = OPSetArtikel.ID
  JOIN Artikel AS SiSArtikel ON SiS.ArtikelID = SiSArtikel.ID
  GROUP BY #LS.StandortID, Artikel.ID
) AS SiSLiefermenge (StandortID, ArtikelID, Liefermenge)
ON OPStats.ArtikelID = SiSLiefermenge.ArtikelID AND OPStats.StandortID = SiSLiefermenge.StandortID
WHEN MATCHED THEN
  UPDATE SET OPStats.Liefermenge = OPStats.Liefermenge + SiSLiefermenge.Liefermenge
WHEN NOT MATCHED THEN
  INSERT (StandortID, ArtikelID, Liefermenge) VALUES (SiSLiefermenge.StandortID, SiSLiefermenge.ArtikelID, SiSLiefermenge.Liefermenge);

MERGE INTO #OPStats AS OPStats
USING (
  SELECT EinzTeil.ArtikelID, s.OPStandortID AS StandortID, COUNT(EinzTeil.ID) AS Schrottmenge
  FROM EinzTeil
  JOIN Vsa ON EinzTeil.VsaID = Vsa.ID
  JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
  JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = Artikel.BereichID
  JOIN #Standort s ON StandBer.ProduktionID = s.StandortID
  WHERE EinzTeil.WegDatum BETWEEN @von AND @bis
    AND EinzTeil.Status = N'Z'
  GROUP BY EinzTeil.ArtikelID, s.OPStandortID
) AS OPSchrott (ArtikelID, StandortID, Schrottmenge)
ON OPStats.ArtikelID = OPSchrott.ArtikelID AND OPStats.StandortID = OPSchrott.StandortID
WHEN MATCHED THEN
  UPDATE SET OPStats.Schrottmenge = OPSchrott.Schrottmenge
WHEN NOT MATCHED THEN
  INSERT (StandortID, ArtikelID, Schrottmenge) VALUES (OPSchrott.StandortID, OPSchrott.ArtikelID, OPSchrott.Schrottmenge);

MERGE INTO #OPStats AS OPStats
USING (
  SELECT EinzTeil.ArtikelID, s.OPStandortID AS StandortID, COUNT(DISTINCT EinzTeil.ID) AS NeuMenge
  FROM Scans
  JOIN EinzTeil ON Scans.EinzTeilID = EinzTeil.ID
  JOIN ArbPlatz ON Scans.ArbPlatzID = ArbPlatz.ID
  JOIN #Standort s ON ArbPlatz.StandortID = s.StandortID
  WHERE Scans.ActionsID = 115 --OP erstellt
    AND Scans.[DateTime] BETWEEN @von AND DATEADD(day, 1, @bis)
    AND Scans.EinzHistID = -1
  GROUP BY EinzTeil.ArtikelID, s.OPStandortID
) AS OPNeu (ArtikelID, StandortID, NeuMenge)
ON OPStats.ArtikelID = OPNeu.ArtikelID AND OPStats.StandortID = OPNeu.StandortID
WHEN MATCHED THEN
  UPDATE SET OPStats.NeuMenge = OPNeu.NeuMenge
WHEN NOT MATCHED THEN
  INSERT (StandortID, ArtikelID, NeuMenge) VALUES (OPNeu.StandortID, OPNeu.ArtikelID, OPNeu.NeuMenge);

INSERT INTO #EinzTeilProd (EinzTeilID, ArtikelID)
SELECT EinzTeil.ID, EinzTeil.ArtikelID
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
WHERE EinzTeil.LastScanTime IS NOT NULL
  AND EinzTeil.LastScanTime > DATEADD(year, -1, GETDATE())
  AND EinzTeil.LastActionsID NOT IN (102, 107, 108)
  AND EinzTeil.[Status] IN (N'A', N'Q')
  AND EinzHist.PoolFkt = 1;

UPDATE #EinzTeilProd SET LastScanID = LastScan.LastScanID
FROM (
  SELECT Scans.EinzTeilID, MAX(Scans.ID) AS LastScanID
  FROM Scans
  GROUP BY Scans.EinzTeilID
) LastScan
WHERE LastScan.EinzTeilID = #EinzTeilProd.EinzTeilID;

MERGE INTO #OPStats AS OPStats
USING (
  SELECT EinzTeilProd.ArtikelID, s.OPStandortID AS StandortID, COUNT(EinzTeilProd.EinzTeilID) AS NeuMenge
  FROM #EinzTeilProd AS EinzTeilProd
  JOIN Scans ON EinzTeilProd.LastScanID = Scans.ID
  JOIN ArbPlatz ON Scans.ArbPlatzID = ArbPlatz.ID
  JOIN #Standort s ON ArbPlatz.StandortID = s.StandortID
  GROUP BY EinzTeilProd.ArtikelID, s.OPStandortID
) AS OPInProd (ArtikelID, StandortID, InProdMenge)
ON OPStats.ArtikelID = OPInProd.ArtikelID AND OPStats.StandortID = OPInProd.StandortID
WHEN MATCHED THEN
  UPDATE SET OPStats.InProd = OPInProd.InProdMenge
WHEN NOT MATCHED THEN
  INSERT (StandortID, ArtikelID, InProd) VALUES (OPInProd.StandortID, OPInProd.ArtikelID, OPInProd.InProdMenge);

WITH Lagerbestand AS (
  SELECT StandortID = 
    CASE Lagerart.LagerID
      WHEN 2 THEN 2
      WHEN 4 THEN 2
      WHEN 4547 THEN 2
      WHEN 5005 THEN 2
      WHEN 5007 THEN 2
      WHEN 5010 THEN 2
      WHEN 5011 THEN 2
      WHEN 5001 THEN 5001
      WHEN 5000 THEN 5001
      WHEN 5212 THEN 5001
      WHEN 5213 THEN 5001
      WHEN 5214 THEN 5001
      WHEN 5133 THEN 5133
      ELSE -1
    END,
  ArtGroe.ArtikelID,
  SUM(Bestand.Bestand) AS Bestand
  FROM Bestand
  JOIN Lagerart ON Bestand.LagerartID = Lagerart.ID
  JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
  WHERE Lagerart.Neuwertig = 1
  GROUP BY
    CASE Lagerart.LagerID
      WHEN 2 THEN 2
      WHEN 4 THEN 2
      WHEN 4547 THEN 2
      WHEN 5005 THEN 2
      WHEN 5007 THEN 2
      WHEN 5010 THEN 2
      WHEN 5011 THEN 2
      WHEN 5001 THEN 5001
      WHEN 5000 THEN 5001
      WHEN 5212 THEN 5001
      WHEN 5213 THEN 5001
      WHEN 5214 THEN 5001
      WHEN 5133 THEN 5133
      ELSE -1
    END,
    ArtGroe.ArtikelID
),
BestelltOffen AS (
  SELECT StandortID =
    CASE BKo.LagerID
      WHEN 2 THEN 2
      WHEN 4 THEN 2
      WHEN 4547 THEN 2
      WHEN 5005 THEN 2
      WHEN 5007 THEN 2
      WHEN 5010 THEN 2
      WHEN 5011 THEN 2
      WHEN 5001 THEN 5001
      WHEN 5000 THEN 5001
      WHEN 5212 THEN 5001
      WHEN 5213 THEN 5001
      WHEN 5214 THEN 5001
      WHEN 5133 THEN 5133
      ELSE -1
    END,
    ArtGroe.ArtikelID,
    SUM(BPo.Menge - BPo.LiefMenge) AS MengeOffen
  FROM BPo
  JOIN BKo ON BPo.BKoID = BKo.ID
  JOIN ArtGroe ON BPo.ArtGroeID = ArtGroe.ID
  WHERE BKo.Status BETWEEN N'F' AND N'K'
    AND BPo.Menge > BPo.LiefMenge
  GROUP BY
    CASE BKo.LagerID
      WHEN 2 THEN 2
      WHEN 4 THEN 2
      WHEN 4547 THEN 2
      WHEN 5005 THEN 2
      WHEN 5007 THEN 2
      WHEN 5010 THEN 2
      WHEN 5011 THEN 2
      WHEN 5001 THEN 5001
      WHEN 5000 THEN 5001
      WHEN 5212 THEN 5001
      WHEN 5213 THEN 5001
      WHEN 5214 THEN 5001
      WHEN 5133 THEN 5133
      ELSE -1
    END,
    ArtGroe.ArtikelID
)
SELECT Standort.Bez AS Produktionsstandort,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  ArtGru.ArtGruBez$LAN$ AS Artikelgruppe,
  OPStats.Liefermenge AS [Liefermenge im Zeitraum],
  OPStats.Schrottmenge AS [Teile verschrottet im Zeitraum],
  ROUND(IIF(OPStats.Liefermenge = 0, 0, CAST(OPStats.Schrottmenge AS float) * 100 / CAST(OPStats.Liefermenge AS float)), 2) AS [Teile verschrottet im Zeitraum prozentual],
  OPStats.NeuMenge AS [Neuteile im Zeitraum],
  ROUND(IIF(OPStats.Liefermenge = 0, 0, CAST(OPStats.NeuMenge AS float) * 100 / CAST(OPStats.Liefermenge AS float)), 2) AS [Neuteile im Zeitraum prozentual],
  OPStats.InProd AS [aktuell in Produktion],
  Lagerbestand.Bestand AS [Neuware im Lager],
  ISNULL(BestelltOffen.MengeOffen, 0) AS [noch offene bestellte Menge]
FROM #OPStats AS OPStats
JOIN Standort ON OPStats.StandortID = Standort.ID
JOIN Artikel ON OPStats.ArtikelID = Artikel.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN Lagerbestand ON Lagerbestand.ArtikelID = Artikel.ID AND Lagerbestand.StandortID = OPStats.StandortID
LEFT JOIN BestelltOffen ON BestelltOffen.ArtikelID = Artikel.ID AND BestelltOffen.StandortID = OPStats.StandortID;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: Liefermenge_je_KW                                                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @von date = $STARTDATE$;
DECLARE @bis date = $ENDDATE$;

DECLARE @Spalten nvarchar(max);
DECLARE @PivotSQL nvarchar(max);

DROP TABLE IF EXISTS #EinzTeilProd;
DROP TABLE IF EXISTS #OPStatsProKW;
DROP TABLE IF EXISTS #OPDatenProKW;
DROP TABLE IF EXISTS #LSproKW;
DROP TABLE IF EXISTS #Standort;
DROP TABLE IF EXISTS #PivotPrepare1;
DROP TABLE IF EXISTS #PivotPrepare2;

CREATE TABLE #EinzTeilProd (
  EinzTeilID int PRIMARY KEY,
  ArtikelID int NOT NULL,
  LastScanID bigint DEFAULT -1
);

CREATE INDEX IX_TmpEinzTeilProd_LastScan ON #EinzTeilProd (LastScanID);

CREATE TABLE #OPStatsProKW (
  StandortID int NOT NULL,
  ArtikelID int NOT NULL,
  Woche nchar(7) COLLATE Latin1_General_CS_AS,
  Liefermenge int NOT NULL DEFAULT 0,
  Schrottmenge int NOT NULL DEFAULT 0
);

CREATE TABLE #OPDatenProKW (
  StandortID int NOT NULL,
  OPEtiPoID int PRIMARY KEY CLUSTERED,
  ArtikelID int,
  EinzTeilID int,
  OPEinwegID int,
  Artikel1ID int,
  Artikel2ID int,
  Woche nchar(7) COLLATE Latin1_General_CS_AS,
  LsMenge numeric(18,4),
  PackmengeSet int,
  Ersatzartikel bit
);
CREATE INDEX IX_TmpOPDaten_EinzTeilID ON #OPDatenProKW (EinzTeilID);

CREATE TABLE #LSproKW (
  LsPoID int PRIMARY KEY,
  StandortID int NOT NULL,
  Woche nchar(7) COLLATE Latin1_General_CS_AS NOT NULL,
  Menge numeric(18,4) NOT NULL,
  KdArtiID int NOT NULL
);

CREATE TABLE #Standort (
  StandortID int,
  OPStandortID int
);

INSERT INTO #Standort (StandortID)
SELECT Standort.ID
FROM Standort
WHERE Standort.ID IN ($3$);

UPDATE #Standort SET OPStandortID = 
  CASE StandortID
    WHEN 2 THEN 2
    WHEN 4 THEN 2
    WHEN 4547 THEN 2
    WHEN 5005 THEN 2
    WHEN 5007 THEN 2
    WHEN 5010 THEN 2
    WHEN 5011 THEN 2
    WHEN 5001 THEN 5001
    WHEN 5000 THEN 5001
    WHEN 5212 THEN 5001
    WHEN 5213 THEN 5001
    WHEN 5214 THEN 5001
    WHEN 5133 THEN 5133
    ELSE -1
  END;

INSERT INTO #LSproKW (LsPoID, StandortID, Woche, Menge, KdArtiID)
SELECT LsPo.ID, s.OPStandortID, [Week].Woche, LsPo.Menge, LsPo.KdArtiID
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN [Week] ON LsKo.Datum BETWEEN [Week].VonDat AND [Week].BisDat
JOIN #Standort s ON LsPo.ProduktionID = s.StandortID
WHERE LsKo.Datum BETWEEN @von AND @bis
  AND LsKo.[Status] >= N'Q';

INSERT INTO #OPDatenProKW (StandortID, OPEtiPoID, ArtikelID, EinzTeilID, OPEinwegID, Artikel1ID, Artikel2ID, Woche, LsMenge, PackmengeSet, Ersatzartikel)
SELECT #LSproKW.StandortID, OPEtiPo.ID AS OPEtiPoID, OPEtiKo.ArtikelID, OPEtiPo.EinzTeilID, OPEtiPo.OPEinwegID, OPSets.Artikel1ID, OPSets.Artikel2ID, #LSproKW.Woche, #LSproKW.Menge AS LsMenge, OPSets.Menge AS PackmengeSet, OPEtiPo.Ersatzartikel
FROM OPEtiPo
JOIN OPEtiKo ON OPEtiPo.OPEtiKoID = OPEtiKo.ID
JOIN OPSets ON OPEtiPo.OPSetsID = OPSets.ID
JOIN #LSproKW ON OPEtiKo.LsPoID = #LSproKW.LsPoID;

INSERT INTO #OPStatsProKW (StandortID, ArtikelID, Woche, Liefermenge)
SELECT #OPDatenProKW.StandortID, EinzTeil.ArtikelID, #OPDatenProKW.Woche, COUNT(#OPDatenProKW.OPEtiPoID) AS Liefermenge
FROM #OPDatenProKW
JOIN EinzTeil ON #OPDatenProKW.EinzTeilID = EinzTeil.ID
WHERE #OPDatenProKW.EinzTeilID > 0
  AND #OPDatenProKW.OPEinwegID = -1
  AND NOT EXISTS (
    SELECT SiS.*
    FROM OPSets AS SiS
    WHERE Sis.ArtikelID = #OPDatenProKW.Artikel1ID
  )
GROUP BY #OPDatenProKW.StandortID, EinzTeil.ArtikelID, #OPDatenProKW.Woche;

MERGE INTO #OPStatsProkW AS OPStats
USING (
  SELECT #OPDatenProKW.StandortID AS StandortID, OPEinweg.ArtikelID, #OPDatenProKW.Woche, COUNT(#OPDatenProKW.OPEtiPoID) AS Liefermenge
  FROM #OPDatenProKW
  JOIN Artikel SetArti ON #OPDatenProKW.ArtikelID = SetArti.ID
  JOIN OPEinweg ON #OPDatenProKW.OPEinwegID = OPEinweg.ID
  WHERE #OPDatenProKW.EinzTeilID = -1
    AND #OPDatenProKW.OPEinwegID > 0
    AND NOT EXISTS (
      SELECT SiS.*
      FROM OPSets AS SiS
      WHERE Sis.ArtikelID = #OPDatenProKW.Artikel1ID
    )
  GROUP BY #OPDatenProKW.StandortID, OPEinweg.ArtikelID, #OPDatenProKW.Woche
) AS NoScanLiefermenge (StandortID, ArtikelID, Woche, Liefermenge)
ON OPStats.ArtikelID = NoScanLiefermenge.ArtikelID AND OPStats.StandortID = NoScanLiefermenge.StandortID AND OPStats.Woche = NoScanLiefermenge.Woche
WHEN MATCHED THEN
  UPDATE SET OPStats.Liefermenge = OPStats.Liefermenge + NoScanLiefermenge.Liefermenge
WHEN NOT MATCHED THEN
  INSERT (StandortID, ArtikelID, Woche, Liefermenge) VALUES (NoScanLiefermenge.StandortID, NoScanLiefermenge.ArtikelID, NoScanLiefermenge.Woche, NoScanLiefermenge.Liefermenge);

MERGE INTO #OPStatsProKW AS OPStats
USING (
  SELECT #OPDatenProKW.StandortID AS StandortID, #OPDatenProKW.Artikel1ID AS ArtikelID, #OPDatenProKW.Woche, SUM(CAST(#OPDatenProKW.LsMenge AS int) * (#OPDatenProKW.PackmengeSet / SetArti.Packmenge)) AS Liefermenge
  FROM #OPDatenProKW
  JOIN Artikel SetArti ON #OPDatenProKW.ArtikelID = SetArti.ID
  WHERE #OPDatenProKW.EinzTeilID = -1
    AND #OPDatenProKW.OPEinwegID = -1
    AND #OPDatenProKW.Ersatzartikel = 0
    AND NOT EXISTS (
      SELECT SiS.*
      FROM OPSets AS SiS
      WHERE Sis.ArtikelID = #OPDatenProKW.Artikel1ID
    )
  GROUP BY #OPDatenProKW.StandortID, #OPDatenProKW.Artikel1ID, #OPDatenProKW.Woche
) AS NoScanLiefermenge (StandortID, ArtikelID, Woche, Liefermenge)
ON OPStats.ArtikelID = NoScanLiefermenge.ArtikelID AND OPStats.StandortID = NoScanLiefermenge.StandortID AND OPStats.Woche = NoScanLiefermenge.Woche
WHEN MATCHED THEN
  UPDATE SET OPStats.Liefermenge = OPStats.Liefermenge + NoScanLiefermenge.Liefermenge
WHEN NOT MATCHED THEN
  INSERT (StandortID, ArtikelID, Woche, Liefermenge) VALUES (NoScanLiefermenge.StandortID, NoScanLiefermenge.ArtikelID, NoScanLiefermenge.Woche, NoScanLiefermenge.Liefermenge);

MERGE INTO #OPStatsProKW AS OPStats
USING (
  SELECT #OPDatenProKW.StandortID AS StandortID, #OPDatenProKW.Artikel2ID AS ArtikelID, #OPDatenProKW.Woche, SUM(CAST(#OPDatenProKW.LsMenge AS int) * (#OPDatenProKW.PackmengeSet / SetArti.Packmenge)) AS Liefermenge
  FROM #OPDatenProKW
  JOIN Artikel SetArti ON #OPDatenProKW.ArtikelID = SetArti.ID
  WHERE #OPDatenProKW.EinzTeilID = -1
    AND #OPDatenProKW.OPEinwegID = -1
    AND #OPDatenProKW.Ersatzartikel = 1
    AND NOT EXISTS (
      SELECT SiS.*
      FROM OPSets AS SiS
      WHERE Sis.ArtikelID = #OPDatenProKW.Artikel1ID
    )
  GROUP BY #OPDatenProKW.StandortID, #OPDatenProKW.Artikel2ID, #OPDatenProKW.Woche
) AS NoScanLiefermenge (StandortID, ArtikelID, Woche, Liefermenge)
ON OPStats.ArtikelID = NoScanLiefermenge.ArtikelID AND OPStats.StandortID = NoScanLiefermenge.StandortID AND OPStats.Woche = NoScanLiefermenge.Woche
WHEN MATCHED THEN
  UPDATE SET OPStats.Liefermenge = OPStats.Liefermenge + NoScanLiefermenge.Liefermenge
WHEN NOT MATCHED THEN
  INSERT (StandortID, ArtikelID, Woche, Liefermenge) VALUES (NoScanLiefermenge.StandortID, NoScanLiefermenge.ArtikelID, NoScanLiefermenge.Woche, NoScanLiefermenge.Liefermenge);

MERGE INTO #OPStatsProKW AS OPStats
USING (
  SELECT #LSproKW.StandortID AS StandortID, Artikel.ID AS ArtikelID, #LSproKW.Woche, SUM(CAST(#LSproKW.Menge AS int) * (OPSets.Menge / OPSetArtikel.Packmenge) * (SiS.Menge / SiSArtikel.Packmenge)) AS Liefermenge
  FROM #LSproKW
  JOIN KdArti ON #LSproKW.KdArtiID = KdArti.ID
  JOIN OPSets ON OPSets.ArtikelID = KdArti.ArtikelID
  JOIN OPSets AS SiS ON OPSets.Artikel1ID = SiS.ArtikelID
  JOIN Artikel ON SiS.Artikel1ID = Artikel.ID
  JOIN Artikel AS OPSetArtikel ON OPSets.ArtikelID = OPSetArtikel.ID
  JOIN Artikel AS SiSArtikel ON SiS.ArtikelID = SiSArtikel.ID
  GROUP BY #LSproKW.StandortID, Artikel.ID, #LsProKW.Woche
) AS SiSLiefermenge (StandortID, ArtikelID, Woche, Liefermenge)
ON OPStats.ArtikelID = SiSLiefermenge.ArtikelID AND OPStats.StandortID = SiSLiefermenge.StandortID AND OPStats.Woche = SiSLiefermenge.Woche
WHEN MATCHED THEN
  UPDATE SET OPStats.Liefermenge = OPStats.Liefermenge + SiSLiefermenge.Liefermenge
WHEN NOT MATCHED THEN
  INSERT (StandortID, ArtikelID, Woche, Liefermenge) VALUES (SiSLiefermenge.StandortID, SiSLiefermenge.ArtikelID, SiSLiefermenge.Woche, SiSLiefermenge.Liefermenge);

SELECT Standort.Bez AS Produktionsstandort,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  ArtGru.ArtGruBez$LAN$ AS Artikelgruppe,
  OPStats.Woche AS Kalenderwoche,
  OPStats.Liefermenge,
  OPStats.Schrottmenge
INTO #PivotPrepare1
FROM #OPStatsProKW AS OPStats
JOIN Standort ON OPStats.StandortID = Standort.ID
JOIN Artikel ON OPStats.ArtikelID = Artikel.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID;

SELECT Produktionsstandort, ArtikelNr, Artikelbezeichnung, Artikelgruppe, Kalenderwoche, c.cname COLLATE Latin1_General_CS_AS + N' ' + Kalenderwoche AS Spaltenname, c.cvalue AS Spaltenwert
INTO #Pivotprepare2
FROM #Pivotprepare1
UNPIVOT(cvalue FOR cname IN (Liefermenge, Schrottmenge)) AS c;

SELECT @Spalten = COALESCE(@Spalten + ', ' + QUOTENAME(Spaltenname), QUOTENAME(Spaltenname), QUOTENAME(N'unbekannt')) FROM (SELECT DISTINCT Kalenderwoche, Spaltenname FROM #PivotPrepare2 WHERE Spaltenname IS NOT NULL) AS K ORDER BY Kalenderwoche, Spaltenname ASC;

IF @Spalten IS NULL
  SELECT N'Keine Daten vorhanden!' AS Error
ELSE
BEGIN
  SET @PivotSQL = '
    SELECT Produktionsstandort, ArtikelNr, Artikelbezeichnung, Artikelgruppe, ' + @Spalten + N'
    FROM (
      SELECT Produktionsstandort, ArtikelNr, Artikelbezeichnung, Artikelgruppe, Spaltenname, Spaltenwert
      FROM #Pivotprepare2
    ) AS x
    PIVOT (
      SUM(Spaltenwert)
      FOR Spaltenname IN (' + @Spalten + ')
    ) AS p';

  EXEC sp_executesql @PivotSQL;
END;