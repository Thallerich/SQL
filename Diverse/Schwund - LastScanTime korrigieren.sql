SET STATISTICS IO, TIME ON;

IF OBJECT_ID(N'tempdb..#SchwundTeile') IS NULL
  CREATE TABLE #SchwundTeile (
    OPTeileID int,
    OPTeilLastScanTime datetime2,
    ScanLastScanTime datetime2,
    NoSchwundLastScanTime datetime2
  );
ELSE
  TRUNCATE TABLE #SchwundTeile;

GO

INSERT INTO #SchwundTeile (OPTeileID, OPTeilLastScanTime, ScanLastScanTime, NoSchwundLastScanTime)
SELECT OPTeile.ID, OPTeile.LastScanTime, LastScan.Zeitpunkt, LastScanNoSchwund.Zeitpunkt
FROM OPTeile
JOIN (
  SELECT OPScans.OPTeileID, MAX(OPScans.Zeitpunkt) AS Zeitpunkt
  FROM OPScans
  GROUP BY OPScans.OPTeileID
) AS LastScan ON LastScan.OPTeileID = OPTeile.ID
JOIN (
  SELECT OPScans.OPTeileID, MAX(OPScans.Zeitpunkt) AS Zeitpunkt
  FROM OPScans
  WHERE OPScans.ActionsID != 116
  GROUP BY OPScans.OPTeileID
) AS LastScanNoSchwund ON LastScanNoSchwund.OPTeileID = OPTeile.ID
WHERE OPTeile.LastActionsID = 116;

GO

BEGIN TRANSACTION;

DISABLE TRIGGER ALL ON OPTeile;

UPDATE OPTeile SET LastScanTime = SchwundTeile.NoSchwundLastScanTime
FROM #SchwundTeile AS SchwundTeile
WHERE SchwundTeile.OPTeileID = OPTeile.ID
  AND SchwundTeile.ScanLastScanTime != SchwundTeile.NoSchwundLastScanTime
  AND SchwundTeile.OPTeilLastScanTime != SchwundTeile.NoSchwundLastScanTime;

ENABLE TRIGGER ALL ON OPTeile;

COMMIT;

GO