SELECT TOP 100 DB_NAME() AS DatabaseName,
  SCHEMA_NAME(t.[schema_id]) AS SchemaName,
  t.name AS TableName,
  ix.name AS IndexName,
  STATS_DATE(ix.id,ix.indid) AS [Last Updated],
  ix.rowcnt AS [Rows],
  ix.rowmodctr AS [Rows changed],
  CAST((CAST(ix.rowmodctr AS DECIMAL(20,8))/CAST(ix.rowcnt AS DECIMAL(20,2)) * 100.0) AS DECIMAL(20,2)) AS [Rows changed %]
FROM sys.sysindexes ix
INNER JOIN sys.tables t ON t.[object_id] = ix.[id]
WHERE ix.id > 100 -- excluding system object statistics
  AND ix.indid > 0 -- excluding heaps or tables that do not any indexes
  AND ix.rowcnt >= 500 -- only indexes with more than 500 rows
ORDER BY [Rows changed] DESC;