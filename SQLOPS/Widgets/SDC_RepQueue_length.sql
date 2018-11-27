SELECT SdcDev.Bez AS Sortieranlage, COUNT(RepQueue.Seq) AS [Queue-Länge]
FROM RepQueue
JOIN SdcDev ON RepQueue.SdcDevID = sdcDev.ID
GROUP BY SdcDev.Bez
ORDER BY sdcDev.Bez;