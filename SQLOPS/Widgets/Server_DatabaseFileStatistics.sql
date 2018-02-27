DECLARE @SQLUsedSpace nvarchar(max);
DECLARE @SQLFreeSpace nvarchar(max);

IF OBJECT_ID('tempdb..#FileInfo') IS NOT NULL
  TRUNCATE TABLE #FileInfo
ELSE
  CREATE TABLE #Fileinfo (
    [Type] int, 
    [Database] nvarchar(128),
    [SpaceMB] decimal(10,0),
    [DBName] nvarchar(128)
  );

SET @SQLUsedSpace = 'USE [?];
INSERT INTO #FileInfo
SELECT 
  1 AS [Type],
  [Database] = 
    CASE 
      WHEN sys.database_files.type_desc = N''ROWS'' THEN DB_NAME()
      WHEN sys.database_files.type_desc = N''LOG'' THEN DB_NAME() + ''_LOG''
    END,
  CONVERT(DECIMAL(10,0), sys.database_files.size / 128.0 - ((sys.database_files.size / 128.0) - CAST(FILEPROPERTY(sys.database_files.name, ''SPACEUSED'') AS int) / 128.0)) AS SpaceMB,
  DB_NAME() AS DBName
FROM sys.database_files;';

SET @SQLFreeSpace = 'USE [?];
INSERT INTO #Fileinfo
SELECT 
  2 AS [Type],
  [Database] = 
    CASE 
      WHEN sys.database_files.type_desc = N''ROWS'' THEN DB_NAME()
      WHEN sys.database_files.type_desc = N''LOG'' THEN DB_NAME() + ''_LOG''
    END,
  CONVERT(DECIMAL(10,0), sys.database_files.size / 128.0 - CAST(FILEPROPERTY(sys.database_files.name, ''SPACEUSED'') AS int) / 128.0) AS SpaceMB,
  DB_NAME() AS DBName
FROM sys.database_files;';

EXEC sp_MSforeachdb @SQLUsedSpace;
EXEC sp_MSforeachdb @SQLFreeSpace;

SELECT [Database], [0] AS [Total], [1] AS [Used], [2] AS Free
FROM (
  SELECT *
  FROM #FileInfo
   WHERE [DBName] NOT IN (N'master', N'model', N'msdb')
    AND [DBName] NOT LIKE N'ReportServer$%'

  UNION ALL

  SELECT 0 AS Type, [Database], SUM(SpaceMB) AS [SpaceMB], [DBName]
  FROM #FileInfo
  WHERE [DBName] NOT IN (N'master', N'model', N'msdb')
    AND [DBName] NOT LIKE N'ReportServer$%'
  GROUP BY [Database], [DBName]
) AS FileStats
PIVOT (
  SUM(SpaceMB)
  FOR Type IN ([0], [1], [2])
) AS FileStatsPivot
ORDER BY [Database] ASC;

DROP TABLE #FileInfo;