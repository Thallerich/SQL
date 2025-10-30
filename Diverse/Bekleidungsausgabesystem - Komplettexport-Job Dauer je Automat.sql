DROP TABLE IF EXISTS #RentoLog;
GO

SELECT LogItem.ID, LogItem.Anlage_ AS Zeitpunkt, LogItem.TableID AS RentomatID, LEFT(LogItem.Bez, CHARINDEX(':', LogItem.Bez, 1) - 1) AS Typ
INTO #RentoLog
FROM LogItem
WHERE LogItem.Anlage_ > '2025-10-28 22:00:00.000'
  AND LogItem.LogCaseID = (SELECT ID FROM LogCase WHERE Bez = 'TMgrRentomat.FullExport')
  AND LogItem.[Version] LIKE 'JOB%';

GO

SELECT N'RUN;KAS_FULLEXPORT' + CAST(RentomatID AS nvarchar) AS ScriptCall, RentomatBez AS Bekleidungsausgabesystem, [Start], [Ende], DATEDIFF(minute, [Start], [Ende]) AS DauerInMinuten
FROM (
  SELECT #RentoLog.RentomatID, #RentoLog.Zeitpunkt, #RentoLog.Typ, Rentomat.Bez AS RentomatBez
  FROM #RentoLog
  JOIN Rentomat ON #RentoLog.RentomatID = Rentomat.ID
  WHERE Rentomat.ID IN (66, 83, 86, 90, 97, 98, 99, 100, 102, 106)
) AS RentoSource
PIVOT (MAX(RentoSource.Zeitpunkt) FOR RentoSource.Typ IN ([Start], [Ende])) AS pvt
ORDER BY [Start] ASC;

GO