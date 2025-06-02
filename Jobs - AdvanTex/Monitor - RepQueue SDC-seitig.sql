DROP TABLE IF EXISTS ##SdcQueueLength, #SdcQueueLength;

DECLARE @sqltext nvarchar(max);
DECLARE @sdcbez nvarchar(40), @linkedserverstring nvarchar(100);

DECLARE SdcDB CURSOR FOR
SELECT SdcDev.Bez, LinkedServerString = CONCAT(N'[', SdcDev.LinkedServerName, N'].', SdcDev.LinkedServerDBName, N'.dbo.REPQUEUE')
FROM SdcDev
WHERE SdcDev.IsTriggerDest = 1;

CREATE TABLE ##SdcQueueLength (
  SDCBez nvarchar(40),
  QueueLength bigint
);

CREATE TABLE #SdcQueueLength (
  SDCBez nvarchar(40),
  QueueLength bigint
);

OPEN SdcDB;

FETCH NEXT FROM SdcDB INTO @sdcbez, @linkedserverstring;

WHILE @@FETCH_STATUS = 0
BEGIN
  IF @linkedserverstring IS NOT NULL
  BEGIN
    SET @sqltext = N'INSERT INTO ##SdcQueueLength (SDCBez, QueueLength) SELECT ''' + @sdcbez + N''', COUNT(*) FROM ' + @linkedserverstring + N' WHERE ErrorCounter < 100 AND SdcDevID = 100';
    PRINT @sqltext;
    BEGIN TRY
      EXEC sp_executesql @sqltext;  
    END TRY
    BEGIN CATCH
    END CATCH;
  END;

  FETCH NEXT FROM SdcDB INTO @sdcbez, @linkedserverstring;
END;

CLOSE SdcDB;
DEALLOCATE SdcDB;

IF (OBJECT_ID('tempdb..##SdcQueueLength') IS NOT NULL AND OBJECT_ID('tempdb..#SdcQueueLength') IS NOT NULL)
BEGIN

  INSERT INTO #SdcQueueLength (SDCBez, QueueLength)
  SELECT SDCBez, QueueLength
  FROM ##SdcQueueLength;

  DROP TABLE ##SdcQueueLength;

END
ELSE
BEGIN
  INSERT INTO #SdcQueueLength (SDCBez, QueueLength)
  SELECT N'Error' AS SdcBez, 0 AS QueueLength;
END;

SELECT * FROM #SdcQueueLength WHERE QueueLength > 1000;