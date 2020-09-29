SET NOCOUNT ON;

DECLARE @rowsmax int = 0;
DECLARE @rowschanged int = 1;
DECLARE @rowsremaining int = 0;
DECLARE @message nvarchar(100);

DECLARE @UpdatedRows TABLE (
  OPTeileID int
);

WITH LastOPScan AS (
  SELECT OPScans.OPTeileID, MAX(OPScans.Zeitpunkt) AS Zeitpunkt
  FROM OPScans
  WHERE OPScans.Zeitpunkt IS NOT NULL
  GROUP BY OPScans.OPTeileID
)
SELECT OPTeile.ID AS OPTeileID, OPTeile.Code, OPTeile.LastScanTime, LastOPScan.Zeitpunkt AS [LastScanTimeFromScans]
INTO #TmpLastScanTime
FROM OPTeile
LEFT JOIN LastOPScan ON OPTeile.ID = LastOPScan.OpTeileID
WHERE OPTeile.ID > 0
  AND OPTeile.LastScanTime IS NULL
  AND LastOPScan.Zeitpunkt IS NOT NULL;

SET @rowsmax = @@ROWCOUNT;
SET @rowsremaining = @rowsmax;

WHILE @rowschanged > 0
BEGIN

  DELETE FROM @UpdatedRows;

  BEGIN TRANSACTION;
  
    UPDATE TOP (50000) OPTeile SET OPTeile.LastScanTime = LastScanTime.LastScanTimeFromScans
    OUTPUT inserted.ID
    INTO @UpdatedRows
    FROM OPTeile
    JOIN #TmpLastScanTime AS LastScanTime ON LastScanTime.OPTeileID = OPTeile.ID;

    SET @rowschanged = @@ROWCOUNT;

    DELETE FROM #TmpLastScanTime
    WHERE OPTeileID IN (
      SELECT OPTeileID
      FROM @UpdatedRows
    );
  
  COMMIT;

  SET @rowsremaining = @rowsremaining - @rowschanged;
  SET @message = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss', N'de-AT') + N' - Updated ' + FORMAT(@rowschanged, N'##,#', N'en-US') + ' rows out of ' + FORMAT(@rowsmax, N'##,#', N'en-US') + '! Rows remaining: ' + FORMAT(@rowsremaining, N'##,#', N'en-US');
  RAISERROR(@message, 0, 1) WITH NOWAIT;

  WAITFOR DELAY '00:00:05';

END;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++                                                                                                                           ++ */
/* ++                                                                                                                           ++ */
/* ++ Author: Stefan Thaller - 2020-09-29                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SET NOCOUNT ON;

DECLARE @rowsmax int = 0;
DECLARE @rowschanged int = 1;
DECLARE @rowsremaining int = 0;
DECLARE @message nvarchar(100);

DECLARE @UpdatedRows TABLE (
  OPTeileID int
);

WITH LastKundenScan AS (
  SELECT OPScans.OPTeileID, MAX(OPScans.Zeitpunkt) AS Zeitpunkt
  FROM OPScans
  WHERE OPScans.ActionsID = 102
    AND OPScans.Zeitpunkt IS NOT NULL
  GROUP BY OPScans.OPTeileID
)
SELECT OPTeile.ID AS OPTeileID, OPTeile.Code, OPTeile.LastScanToKunde, LastKundenScan.Zeitpunkt AS [LastKundenScanFromScans]
INTO #TmpLastKundenScan
FROM OPTeile
LEFT JOIN LastKundenScan ON OPTeile.ID = LastKundenScan.OPTeileID
WHERE OPTeile.ID > 0
  AND OPTeile.LastScanToKunde IS NULL 
  AND LastKundenScan.Zeitpunkt IS NOT NULL;

SET @rowsmax = @@ROWCOUNT;
SET @rowsremaining = @rowsmax;

WHILE @rowschanged > 0
BEGIN

  DELETE FROM @UpdatedRows;

  BEGIN TRANSACTION;
  
    UPDATE TOP (50000) OPTeile SET OPTeile.LastScanToKunde = LastScanTime.LastKundenScanFromScans
    OUTPUT inserted.ID
    INTO @UpdatedRows
    FROM OPTeile
    JOIN #TmpLastKundenScan AS LastScanTime ON LastScanTime.OPTeileID = OPTeile.ID;

    SET @rowschanged = @@ROWCOUNT;

    DELETE FROM #TmpLastKundenScan
    WHERE OPTeileID IN (
      SELECT OPTeileID
      FROM @UpdatedRows
    );
  
  COMMIT;

  SET @rowsremaining = @rowsremaining - @rowschanged;
  SET @message = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss', N'de-AT') + N' - Updated ' + FORMAT(@rowschanged, N'##,#', N'en-US') + ' rows out of ' + FORMAT(@rowsmax, N'##,#', N'en-US') + '! Rows remaining: ' + FORMAT(@rowsremaining, N'##,#', N'en-US');
  RAISERROR(@message, 0, 1) WITH NOWAIT;

  WAITFOR DELAY '00:00:05';

END;