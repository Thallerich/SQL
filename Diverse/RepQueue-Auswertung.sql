SELECT Priority, TableName, ISNULL([11], 0) AS Enns, ISNULL([3], 0) AS [Enns 2], ISNULL([1], 0) AS [Lenzing 1], ISNULL([2], 0) AS [Lenzing 2], ISNULL([21], 0) AS Klagenfurt, ISNULL([31], 0) AS Bratislava, ISNULL([41], 0) AS Graz, ISNULL([51], 0) AS [Wr. Neustadt], ISNULL([61], 0) AS SA22, ISNULL([106], 0) AS Inzing 
FROM (
  SELECT SdcDev.ID AS SdcDevID, RepQueue.Priority, RepQueue.TableName, COUNT(DISTINCT RepQueue.TableID) AS AnzahlDS
  FROM RepQueue WITH (NOLOCK)
  JOIN SdcDev WITH (NOLOCK) ON RepQueue.SdcDevID = SdcDev.ID
  --WHERE RepQueue.Priority < 900
  GROUP BY SdcDev.ID, RepQueue.TableName, RepQueue.Priority
) AS RepQueueData
PIVOT (
  SUM(AnzahlDS)
  FOR SdcDevID IN ([11], [3], [1], [2], [21], [31], [41], [51], [61], [106])
) AS SDCPivot
ORDER BY [Priority] ASC;