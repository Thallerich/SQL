IF OBJECT_ID(N'tempdb..#InvUpdate', N'U') IS NULL
BEGIN
  CREATE TABLE #InvUpdate (
    OPTeileID int PRIMARY KEY,
    ZielNrID int,
    LastActionsID int
  );
END ELSE BEGIN
  TRUNCATE TABLE #InvUpdate;
END;

IF OBJECT_ID(N'tempdb..#InvDelete', N'U') IS NULL
BEGIN
  CREATE TABLE #InvDelete (
    OPTeileID int PRIMARY KEY
  );
END ELSE BEGIN
  TRUNCATE TABLE #InvDelete;
END;

GO

WITH LastScan AS (
  SELECT MAX(OPScans.Zeitpunkt) AS LastScanTime, OPScans.OPTeileID
  FROM OPScans
  WHERE OPScans.ZielNrID != 100070077
  GROUP BY OPScans.OPTeileID
)
INSERT INTO #InvUpdate (OPTeileID, ZielNrID, LastActionsID)
SELECT OPTeile.ID, OPScans.ZielNrID, OPScans.ActionsID
FROM OPTeile
JOIN LastScan ON OPTeile.ID = LastScan.OPTeileID
JOIN OPScans ON LastScan.LastScanTime = OPScans.Zeitpunkt AND OPTeile.ID = OPScans.OPTeileID
WHERE OPTeile.ZielNrID = 100070077
  AND OPTeile.LastScanTime < N'2021-11-25 00:00:00';

GO

INSERT INTO #InvDelete (OPTeileID)
SELECT OPTeile.ID
FROM OPTeile
WHERE OPTeile.ZielNrID = 100070077
  AND OPTeile.LastScanTime < N'2021-11-25 00:00:00'
  AND OPTeile.ID NOT IN (
    SELECT InvUpdate.OPTeileID
    FROM #InvUpdate AS InvUpdate
  );

GO

UPDATE OPTeile SET ZielNrID = InvUpdate.ZielNrID, LastActionsID = InvUpdate.LastActionsID
FROM OPTeile
JOIN #InvUpdate AS InvUpdate ON OPTeile.ID = InvUpdate.OPTeileID;

GO

UPDATE OPTeile SET ZielNrID = 10000060, LastActionsID = 115
FROM OPTeile
WHERE OPTeile.ID IN (
  SELECT OPTeileID
  FROM #InvDelete
);

DELETE FROM OPScans WHERE OPTeileID IN (
  SELECT OPTeileID
  FROM #InvDelete
);

GO