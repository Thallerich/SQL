WITH LastOPScan AS (
  SELECT OPScans.OPTeileID, MAX(OPScans.Zeitpunkt) AS Zeitpunkt
  FROM OPScans
  GROUP BY OPScans.OPTeileID
)
SELECT OPTeile.ID AS OPTeileID, OPTeile.Code, OPTeile.LastScanTime, LastOPScan.Zeitpunkt AS [LastScanTimeFromScans]
FROM OPTeile
LEFT JOIN LastOPScan ON OPTeile.ID = LastOPScan.OpTeileID
WHERE OPTeile.ID > 0
  AND OPTeile.LastScanTime IS NULL
  AND LastOPScan.Zeitpunkt IS NOT NULL;

WITH LastKundenScan AS (
  SELECT OPScans.OPTeileID, MAX(OPScans.Zeitpunkt) AS Zeitpunkt
  FROM OPScans
  WHERE OPScans.ActionsID = 102
  GROUP BY OPScans.OPTeileID
)
SELECT OPTeile.ID AS OPTeileID, OPTeile.Code, OPTeile.LastScanToKunde, LastKundenScan.Zeitpunkt AS [LastKundenScanFromScans]
FROM OPTeile
LEFT JOIN LastKundenScan ON OPTeile.ID = LastKundenScan.OPTeileID
WHERE OPTeile.ID > 0
  AND OPTeile.LastScanToKunde IS NULL 
  AND LastKundenScan.Zeitpunkt IS NOT NULL;