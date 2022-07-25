--This code is a modified or extended version of a script from here:
--http://www.sqlskills.com/blogs/erin/new-statistics-dmf-in-sql-server-2008r2-sp2/ 
 
/*
This script will give all metadata related to statistics for a single database.
You can also uncomment a line and add an object name for a single table. 
 
Final challenge was to get one row per statistics with all column names. Used the tips from
https://www.mssqltips.com/sqlservertip/2914/rolling-up-multiple-rows-into-a-single-row-and-column-for-sql-server-data/
Suneel Mundlapudi who is a Sr. SQL Server Database Consultant at Fresenius Medical Care helped me implementing STUFF function
*/
 
USE [Salesianer];
GO
 
IF Object_id('tempdb..#StatsInfo') IS NOT NULL
  DROP TABLE #statsinfo;
GO
 
IF Object_id('tempdb..#ColumnList') IS NOT NULL
  DROP TABLE #columnlist;
GO
 
DECLARE @object_id INT =NULL; 
 
--By default you get statistics status for whole database
--Uncomment below line if you are only looking at one table
--SET @object_id = OBJECT_ID(N'Sales.Invoices');
SELECT
  ss.[name] AS SchemaName,
  obj.[name] AS TableName,
  stat.[stats_id],
  stat.[name] AS StatisticsName,
  CASE
    WHEN stat.[auto_created] = 0
    AND stat.[user_created] = 0 THEN 'Index Statistic'
    WHEN stat.[auto_created] = 0
    AND stat.[user_created] = 1 THEN 'User Created'
    WHEN stat.[auto_created] = 1
    AND stat.[user_created] = 0  THEN 'Auto Created'
    WHEN stat.[auto_created] = 1
    AND stat.[user_created] = 1 THEN 'Updated stats available in Secondary'
  END AS StatisticType,
  CASE
    WHEN stat.[is_temporary] = 0 THEN 'Stats in DB'
    WHEN stat.[is_temporary] = 1 THEN 'Stats in Tempdb'
  END AS IsTemporary,
  CASE
    WHEN stat.[has_filter] = 1 THEN 'Filtered Index'
    WHEN stat.[has_filter] = 0 THEN 'No Filter'
  END AS IsFiltered,
  c.[name] AS ColumnName,
  stat.[filter_definition],
  sp.[last_updated],
  sp.[rows],
  sp.[rows_sampled],
  sp.[steps] AS HistorgramSteps,
  sp.[unfiltered_rows],
  sp.[modification_counter] AS RowsModified
INTO #statsinfo
FROM  
  sys.[objects] AS obj
  INNER JOIN sys.[schemas] ss
    ON obj.[schema_id] = ss.[schema_id]
  INNER JOIN sys.[stats] stat
    ON stat.[object_id] = obj.[object_id]
  JOIN sys.[stats_columns] sc
    ON sc.[object_id] = stat.[object_id]
    AND sc.[stats_id] = stat.[stats_id]
  JOIN sys.columns c
    ON c.[object_id] = sc.[object_id]
    AND c.[column_id] = sc.[column_id]
  CROSS apply sys.Dm_db_stats_properties(stat.object_id, stat.stats_id) AS sp
WHERE 
  ( obj.[is_ms_shipped] = 0
  AND obj.[object_id] = @object_id )
  OR ( obj.[is_ms_shipped] = 0 )
ORDER BY
  ss.[name],
  obj.[name],
  stat.[name]; 
 
SELECT
  t.[schemaname],
  t.[tablename],
  t.[stats_id],
  Stuff((SELECT ',' + s.[columnname]
FROM
  #statsinfo s
WHERE 
  s.[schemaname] = t.[schemaname]
  AND s.[tablename] = t.[tablename]
  AND s.stats_id = t.stats_id
FOR xml path('')), 1, 1, '') AS ColumnList
INTO   #columnlist
FROM   #statsinfo AS t
GROUP BY
  t.[schemaname],
  t.[tablename],
  t.[stats_id]; 
 
SELECT DISTINCT
  SI.[schemaname],
  SI.[tablename],
  SI.[stats_id],
  SI.[statisticsname],
  SI.[statistictype],
  SI.[istemporary],
  CL.[columnlist] AS ColumnName,
  SI.[isfiltered],
  SI.[filter_definition],
  SI.[last_updated],
  SI.[rows],
  SI.[rows_sampled],
  SI.[historgramsteps],
  SI.[unfiltered_rows],
  SI.[rowsmodified]
FROM  
  #statsinfo SI
  INNER JOIN #columnlist CL
  ON SI.[schemaname] = CL.[schemaname]
  AND SI.[tablename] = CL.[tablename]
  AND SI.[stats_id] = CL.[stats_id]
WHERE SI.RowsModified > 0
  AND SI.last_updated < N'2022-07-24 00:00:00'
ORDER BY
  SI.RowsModified DESC;
GO