DROP TABLE IF EXISTS #RepQueueMonitor;

SELECT SdcDev.Bez, RepQueue.TableName, COUNT(DISTINCT RepQueue.TableID) AS AnzahlDS
INTO #RepQueueMonitor
FROM RepQueue WITH (NOLOCK)
JOIN SdcDev WITH (NOLOCK) ON RepQueue.SdcDevID = SdcDev.ID
WHERE RepQueue.Priority <= (SELECT MAX(TabName.Folge) FROM dbSystem.dbo.TabName)
GROUP BY SdcDev.Bez, RepQueue.TableName
HAVING COUNT(DISTINCT RepQueue.TableID) > 100000;

DECLARE @pivotcols nvarchar(max), @pivotsql nvarchar(max);

SET @pivotcols = STUFF((SELECT DISTINCT N', [' + Bez + N']' FROM #RepQueueMonitor ORDER BY 1 FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, N'');

SET @pivotsql = N'
SELECT TableName, ' + @pivotcols + N'
FROM #RepQueueMonitor AS RepQueueData
PIVOT (
  SUM(AnzahlDS)
  FOR Bez IN (' + @pivotcols + N')
) AS SDCPivot
ORDER BY TableName ASC;
';

EXEC sp_executesql @pivotsql;