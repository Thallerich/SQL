DROP TABLE IF EXISTS #PoolQueue;
GO

CREATE TABLE #PoolQueue (
  QueueBez nvarchar(40),
  Zeit nchar(5),
  InQueue int
);

GO

DECLARE @startDate datetime2, @endDate datetime2, @sqltext nvarchar(max);

SET @startDate = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), DAY(GETDATE()));
SET @endDate= GETDATE();

SET @sqltext = N'
INSERT INTO #PoolQueue (QueueBez, Zeit, InQueue)
SELECT SdcDev.Bez, FORMAT(ServLog.Zeitpunkt, N''HH:mm'') AS Zeit, ServLog.Wert AS InQueue
FROM ServLog
JOIN SdcDev ON ServLog.InfoText = CAST(SdcDev.ID AS nvarchar)
WHERE ServLog.ServStatID = (SELECT ID FROM ServStat WHERE SvcKeyName = ''SdcPoolSQueue'')
  AND ServLog.Zeitpunkt BETWEEN @startDate AND @endDate;
';

EXEC sp_executesql @sqltext, N'@startDate datetime2, @endDate datetime2', @startDate, @endDate;

GO

DECLARE @pivotcols nvarchar(max), @pivotsql nvarchar(max);

SET @pivotcols = STUFF((SELECT DISTINCT ', [' + Zeit + ']' FROM #PoolQueue ORDER BY 1 FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,1,'');
SET @pivotsql = N'SELECT QueueBez, ' + @pivotcols + ' FROM #PoolQueue AS Pivotdata PIVOT (SUM(InQueue) FOR Zeit IN (' + @pivotcols + ')) AS p;';

EXEC sp_executesql @pivotsql;

GO