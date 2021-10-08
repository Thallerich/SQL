DECLARE @von date = $1$;
DECLARE @bis date = $2$;

DECLARE @StandortID int = 
  CASE $3$
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
    ELSE NULL
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
SELECT @StandortID AS StandortID, Artikel.ID AS ArtikelID, SUM(CAST(LsPo.Menge AS int) * (OPSets.Menge / OPSetArtikel.Packmenge)) AS Liefermenge
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN OPSets ON OPSets.ArtikelID = KdArti.ArtikelID
JOIN Artikel ON OPSets.Artikel1ID = Artikel.ID
JOIN Standort ON LsPo.ProduktionID = Standort.ID
JOIN Artikel AS OPSetArtikel ON OPSets.ArtikelID = OPSetArtikel.ID
WHERE LsKo.Datum BETWEEN @von AND @bis
  AND LsPo.ProduktionID = $3$
  AND NOT EXISTS (
    SELECT SiS.*
    FROM OPSets AS SiS
    WHERE Sis.ArtikelID = OPSets.Artikel1ID
  )
GROUP BY Standort.ID, Artikel.ID;

MERGE INTO @OPStats AS OPStats
USING (
  SELECT @StandortID AS StandortID, Artikel.ID AS ArtikelID, SUM(CAST(LsPo.Menge AS int) * (OPSets.Menge / OPSetArtikel.Packmenge) * (SiS.Menge / SiSArtikel.Packmenge)) AS Liefermenge
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
  JOIN OPSets ON OPSets.ArtikelID = KdArti.ArtikelID
  JOIN OPSets AS SiS ON OPSets.Artikel1ID = SiS.ArtikelID
  JOIN Artikel ON SiS.Artikel1ID = Artikel.ID
  JOIN Standort ON LsPo.ProduktionID = Standort.ID
  JOIN Artikel AS OPSetArtikel ON OPSets.ArtikelID = OPSetArtikel.ID
  JOIN Artikel AS SiSArtikel ON SiS.ArtikelID = SiSArtikel.ID
  WHERE LsKo.Datum BETWEEN @von AND @bis
    AND LsPo.ProduktionID = $3$
  GROUP BY Standort.ID, Artikel.ID
) AS SiSLiefermenge (StandortID, ArtikelID, Liefermenge)
ON OPStats.ArtikelID = SiSLiefermenge.ArtikelID AND OPStats.StandortID = SiSLiefermenge.StandortID
WHEN MATCHED THEN
  UPDATE SET OPStats.Liefermenge = OPStats.Liefermenge + SiSLiefermenge.Liefermenge
WHEN NOT MATCHED THEN
  INSERT (StandortID, ArtikelID, Liefermenge) VALUES (SiSLiefermenge.StandortID, SiSLiefermenge.ArtikelID, SiSLiefermenge.Liefermenge);

MERGE INTO @OPStats AS OPStats
USING (
  SELECT OPTeile.ArtikelID, @StandortID AS StandortID, COUNT(OPTeile.ID) AS Schrottmenge
  FROM OPTeile
  JOIN Vsa ON OPTeile.VsaID = Vsa.ID
  JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
  JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = Artikel.BereichID
  WHERE OPTeile.WegDatum BETWEEN @von AND @bis
    AND StandBer.ProduktionID = $3$
    AND OPTeile.Status = N'Z'
  GROUP BY OPTeile.ArtikelID
) AS OPSchrott (ArtikelID, StandortID, Schrottmenge)
ON OPStats.ArtikelID = OPSchrott.ArtikelID AND OPStats.StandortID = OPSchrott.StandortID
WHEN MATCHED THEN
  UPDATE SET OPStats.Schrottmenge = OPSchrott.Schrottmenge
WHEN NOT MATCHED THEN
  INSERT (StandortID, ArtikelID, Schrottmenge) VALUES (OPSchrott.StandortID, OPSchrott.ArtikelID, OPSchrott.Schrottmenge);

MERGE INTO @OPStats AS OPStats
USING (
  SELECT OPTeile.ArtikelID, @StandortID AS StandortID, COUNT(DISTINCT OPTeile.ID) AS NeuMenge
  FROM OPScans
  JOIN OPTeile ON OPScans.OPTeileID = OPTeile.ID
  JOIN ArbPlatz ON OPScans.ArbPlatzID = ArbPlatz.ID
  WHERE OPScans.ActionsID = 115 --OP erstellt
    AND ArbPlatz.StandortID = @StandortID
    AND OPScans.Zeitpunkt BETWEEN @von AND DATEADD(day, 1, @bis)
  GROUP BY OPTeile.ArtikelID
) AS OPNeu (ArtikelID, StandortID, NeuMenge)
ON OPStats.ArtikelID = OPNeu.ArtikelID AND OPStats.StandortID = OPNeu.StandortID
WHEN MATCHED THEN
  UPDATE SET OPStats.NeuMenge = OPNeu.NeuMenge
WHEN NOT MATCHED THEN
  INSERT (StandortID, ArtikelID, NeuMenge) VALUES (OPNeu.StandortID, OPNeu.ArtikelID, OPNeu.NeuMenge);

MERGE INTO @OPStats AS OPStats
USING (
  SELECT OPTeil.ArtikelID, @StandortID AS StandortID, COUNT(DISTINCT OPTeil.ID) AS NeuMenge
  FROM (
    SELECT OPTeile.ID, OPTeile.ArtikelID, OPTeile.LastActionsID, OPTeile.LastScanTime, MAX(OPScans.ID) AS LastOPScanID
    FROM OPTeile
    JOIN OPScans ON OPScans.OPTeileID = OPTeile.ID
    WHERE ISNULL(OPTeile.LastScanTime, N'1980-01-01 00:00:00') > DATEADD(year, -1, GETDATE())
      AND OPTeile.LastActionsID NOT IN (102, 107, 108)  -- OP Auslesen, OP Lager, OP Schrott
    GROUP BY OPTeile.ID, OPTeile.ArtikelID, OPTeile.LastActionsID, OPTeile.LastScanTime
  ) AS OPTeil
  JOIN OPScans ON OPTeil.LastOPScanID = OPScans.ID
  JOIN ArbPlatz ON OPScans.ArbPlatzID = ArbPlatz.ID
  WHERE ArbPlatz.StandortID = @StandortID
  GROUP BY OPTeil.ArtikelID
) AS OPInProd (ArtikelID, StandortID, InProdMenge)
ON OPStats.ArtikelID = OPInProd.ArtikelID AND OPStats.StandortID = OPInProd.StandortID
WHEN MATCHED THEN
  UPDATE SET OPStats.InProd = OPInProd.InProdMenge
WHEN NOT MATCHED THEN
  INSERT (StandortID, ArtikelID, InProd) VALUES (OPInProd.StandortID, OPInProd.ArtikelID, OPInProd.InProdMenge);

SELECT Standort.Bez AS Produktionsstandort, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGru.ArtGruBez$LAN$ AS Artikelgruppe, OPStats.Liefermenge AS [Liefermenge im Zeitraum], OPStats.Schrottmenge AS [Teile verschrottet im Zeitraum], OPStats.NeuMenge AS [Neuteile im Zeitraum], OPStats.InProd AS [aktuell in Produktion]
FROM @OPStats AS OPStats
JOIN Standort ON OPStats.StandortID = Standort.ID
JOIN Artikel ON OPStats.ArtikelID = Artikel.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID;