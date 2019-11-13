SELECT TableName, Priority, ISNULL([11], 0) AS Enns, ISNULL([3], 0) AS [Enns 2], ISNULL([1], 0) AS [Lenzing 1], ISNULL([2], 0) AS [Lenzing 2], ISNULL([21], 0) AS Klagenfurt 
FROM (
  SELECT SdcDev.ID AS SdcDevID, RepQueue.TableName, RepQueue.Priority, COUNT(DISTINCT RepQueue.TableID) AS AnzahlDS
  FROM RepQueue WITH (NOLOCK)
  JOIN SdcDev ON RepQueue.SdcDevID = SdcDev.ID
  GROUP BY SdcDev.ID, RepQueue.TableName, RepQueue.Priority
) AS RepQueueData
PIVOT (
  SUM(AnzahlDS)
  FOR SdcDevID IN ([11], [3], [1], [2], [21])
) AS SDCPivot
ORDER BY [Priority] ASC;