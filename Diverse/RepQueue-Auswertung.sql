SELECT TableName, Priority, [11] AS Enns, [3] AS [Enns 2], [1] AS [Lenzing 1], [2] AS [Lenzing 2], [21] AS Klagenfurt 
FROM (
  SELECT SdcDev.ID AS SdcDevID, RepQueue.TableName, RepQueue.Priority, COUNT(DISTINCT RepQueue.TableID) AS AnzahlDS
  FROM RepQueue
  JOIN SdcDev ON RepQueue.SdcDevID = SdcDev.ID
  GROUP BY SdcDev.ID, RepQueue.TableName, RepQueue.Priority
) AS RepQueueData
PIVOT (
  SUM(AnzahlDS)
  FOR SdcDevID IN ([11], [3], [1], [2], [21])
) AS SDCPivot
ORDER BY [Priority] ASC;