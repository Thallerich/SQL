SELECT SdcDev.Bez AS Sortieranlage, COUNT(RepQueue.Seq) AS [Queue-Länge]
FROM RepQueue
RIGHT OUTER JOIN SdcDev ON RepQueue.SdcDevID = sdcDev.ID
WHERE SdcDev.IsTriggerDest = 1
GROUP BY SdcDev.Bez

UNION ALL

SELECT SdcDev.Bez AS Sortieranlage, COUNT(SdcScan.ID) AS [Queue-Länge]
FROM SdcScan
JOIN SdcDev ON SdcScan.AdvInstID = SdcDev.ID
GROUP BY SdcDev.Bez

UNION ALL

SELECT N'Z_UHF Einlesen' AS Sortieranlage, COUNT(SdcPools.ID) AS [Queue-Länge]
FROM SdcPools

UNION ALL

SELECT N'Z_UHF Count-IT' AS Sortieranlage, COUNT(_CITRepQ.ID) AS [Queue-Länge]
FROM _CITRepQ
ORDER BY Sortieranlage ASC;