SELECT [FileName] AS [File], COUNT(*) AS [growths]
FROM ::fn_trace_gettable('E:\SQL Server\MSSQL13.ADVANTEX\MSSQL\Log\log.trc',0)
INNER JOIN sys.trace_events e ON eventclass = trace_event_id
INNER JOIN sys.trace_categories AS cat ON e.category_id = cat.category_id
WHERE DatabaseName = DB_NAME() 
  AND cat.category_id = 2 
  AND e.trace_event_id IN (92,93)
GROUP BY [FileName]
ORDER BY [FileName] DESC;