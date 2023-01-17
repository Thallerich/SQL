DECLARE @von date = $1$;
DECLARE @bis date = $2$;

DECLARE @Standort TABLE (
  StandortID int,
  OPStandortID int
);

IF OBJECT_ID(N'tempdb..#EinzTeilProd') IS NULL
BEGIN
  CREATE TABLE #EinzTeilProd (
    EinzTeilID int PRIMARY KEY,
    ArtikelID int NOT NULL,
    LastScanID bigint DEFAULT -1
  );
END ELSE BEGIN
  TRUNCATE TABLE #EinzTeilProd;
END;

INSERT INTO @Standort (StandortID)
SELECT Standort.ID
FROM Standort
WHERE Standort.ID IN ($3$);

UPDATE @Standort SET OPStandortID = 
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

DECLARE @OPStats TABLE (
  StandortID int DEFAULT NULL,
  ArtikelID int DEFAULT NULL,
  Liefermenge int DEFAULT 0,
  Schrottmenge int DEFAULT 0,
  NeuMenge int DEFAULT 0,
  InProd int DEFAULT 0
);

INSERT INTO @OPStats (StandortID, ArtikelID, Liefermenge)
SELECT s.OPStandortID AS StandortID, Artikel.ID AS ArtikelID, SUM(CAST(LsPo.Menge AS int) * (OPSets.Menge / OPSetArtikel.Packmenge)) AS Liefermenge
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN OPSets ON OPSets.ArtikelID = KdArti.ArtikelID
JOIN Artikel ON OPSets.Artikel1ID = Artikel.ID
JOIN @Standort s ON LsPo.ProduktionID = s.StandortID
JOIN Artikel AS OPSetArtikel ON OPSets.ArtikelID = OPSetArtikel.ID
WHERE LsKo.Datum BETWEEN @von AND @bis
  AND NOT EXISTS (
    SELECT SiS.*
    FROM OPSets AS SiS
    WHERE Sis.ArtikelID = OPSets.Artikel1ID
  )
GROUP BY s.OPStandortID, Artikel.ID;

MERGE INTO @OPStats AS OPStats
USING (
  SELECT s.OPStandortID AS StandortID, Artikel.ID AS ArtikelID, SUM(CAST(LsPo.Menge AS int) * (OPSets.Menge / OPSetArtikel.Packmenge) * (SiS.Menge / SiSArtikel.Packmenge)) AS Liefermenge
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
  JOIN OPSets ON OPSets.ArtikelID = KdArti.ArtikelID
  JOIN OPSets AS SiS ON OPSets.Artikel1ID = SiS.ArtikelID
  JOIN Artikel ON SiS.Artikel1ID = Artikel.ID
  JOIN @Standort s ON LsPo.ProduktionID = s.StandortID
  JOIN Artikel AS OPSetArtikel ON OPSets.ArtikelID = OPSetArtikel.ID
  JOIN Artikel AS SiSArtikel ON SiS.ArtikelID = SiSArtikel.ID
  WHERE LsKo.Datum BETWEEN @von AND @bis
  GROUP BY s.OPStandortID, Artikel.ID
) AS SiSLiefermenge (StandortID, ArtikelID, Liefermenge)
ON OPStats.ArtikelID = SiSLiefermenge.ArtikelID AND OPStats.StandortID = SiSLiefermenge.StandortID
WHEN MATCHED THEN
  UPDATE SET OPStats.Liefermenge = OPStats.Liefermenge + SiSLiefermenge.Liefermenge
WHEN NOT MATCHED THEN
  INSERT (StandortID, ArtikelID, Liefermenge) VALUES (SiSLiefermenge.StandortID, SiSLiefermenge.ArtikelID, SiSLiefermenge.Liefermenge);

MERGE INTO @OPStats AS OPStats
USING (
  SELECT EinzTeil.ArtikelID, s.OPStandortID AS StandortID, COUNT(EinzTeil.ID) AS Schrottmenge
  FROM EinzTeil
  JOIN Vsa ON EinzTeil.VsaID = Vsa.ID
  JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
  JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = Artikel.BereichID
  JOIN @Standort s ON StandBer.ProduktionID = s.StandortID
  WHERE EinzTeil.WegDatum BETWEEN @von AND @bis
    AND EinzTeil.Status = N'Z'
  GROUP BY EinzTeil.ArtikelID, s.OPStandortID
) AS OPSchrott (ArtikelID, StandortID, Schrottmenge)
ON OPStats.ArtikelID = OPSchrott.ArtikelID AND OPStats.StandortID = OPSchrott.StandortID
WHEN MATCHED THEN
  UPDATE SET OPStats.Schrottmenge = OPSchrott.Schrottmenge
WHEN NOT MATCHED THEN
  INSERT (StandortID, ArtikelID, Schrottmenge) VALUES (OPSchrott.StandortID, OPSchrott.ArtikelID, OPSchrott.Schrottmenge);

MERGE INTO @OPStats AS OPStats
USING (
  SELECT EinzTeil.ArtikelID, s.OPStandortID AS StandortID, COUNT(DISTINCT EinzTeil.ID) AS NeuMenge
  FROM Scans
  JOIN EinzTeil ON Scans.EinzTeilID = EinzTeil.ID
  JOIN ArbPlatz ON Scans.ArbPlatzID = ArbPlatz.ID
  JOIN @Standort s ON ArbPlatz.StandortID = s.StandortID
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
WHERE ISNULL(EinzTeil.LastScanTime, N'1980-01-01 00:00:00') > DATEADD(year, -1, GETDATE())
    AND EinzTeil.LastActionsID NOT IN (102, 107, 108);

UPDATE #EinzTeilProd SET LastScanID = LastScan.LastScanID
FROM (
  SELECT EinzTeilProd.EinzTeilID, MAX(Scans.ID) AS LastScanID
  FROM #EinzTeilProd AS EinzTeilProd
  JOIN Scans ON Scans.EinzTeilID = EinzTeilProd.EinzTeilID
  GROUP BY EinzTeilProd.EinzTeilID
) LastScan
WHERE LastScan.EinzTeilID = #EinzTeilProd.EinzTeilID;

MERGE INTO @OPStats AS OPStats
USING (
  SELECT EinzTeilProd.ArtikelID, s.OPStandortID AS StandortID, COUNT(DISTINCT EinzTeilProd.EinzTeilID) AS NeuMenge
  FROM #EinzTeilProd AS EinzTeilProd
  JOIN Scans ON EinzTeilProd.LastScanID = Scans.ID
  JOIN ArbPlatz ON Scans.ArbPlatzID = ArbPlatz.ID
  JOIN @Standort s ON ArbPlatz.StandortID = s.StandortID
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
FROM @OPStats AS OPStats
JOIN Standort ON OPStats.StandortID = Standort.ID
JOIN Artikel ON OPStats.ArtikelID = Artikel.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN Lagerbestand ON Lagerbestand.ArtikelID = Artikel.ID AND Lagerbestand.StandortID = OPStats.StandortID
LEFT JOIN BestelltOffen ON BestelltOffen.ArtikelID = Artikel.ID AND BestelltOffen.StandortID = OPStats.StandortID;