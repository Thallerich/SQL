SELECT SdcDev.Bez AS Sortieranlage, COUNT(DISTINCT RepQueue.TableName + N' -- ' + CAST(RepQueue.TableID AS nvarchar)) AS [Queue-Länge]
FROM RepQueue WITH (NOLOCK, READUNCOMMITTED)
RIGHT OUTER JOIN SdcDev ON RepQueue.SdcDevID = sdcDev.ID
WHERE SdcDev.IsTriggerDest = 1
GROUP BY SdcDev.Bez

UNION ALL

SELECT SdcDev.Bez AS Sortieranlage, COUNT(SdcScan.ID) AS [Queue-Länge]
FROM SdcScan
JOIN SdcDev ON SdcScan.AdvInstID = SdcDev.ID
GROUP BY SdcDev.Bez

ORDER BY Sortieranlage ASC;