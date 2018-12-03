SELECT SdcDev.Bez AS Sortieranlage, COUNT(RepQueue.Seq) AS [Queue-Länge]
FROM RepQueue
RIGHT OUTER JOIN SdcDev ON RepQueue.SdcDevID = sdcDev.ID
WHERE SdcDev.IsTriggerDest = 1
GROUP BY SdcDev.Bez
ORDER BY sdcDev.Bez;