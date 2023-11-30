SELECT SdcDev.Bez AS [Sortieranlage], COUNT(SdcScan.ID) AS [Queue-Länge Feedbackverarbeitung]
FROM SdcScan
JOIN SdcDev ON SdcScan.SdcDevID = SdcDev.ID
GROUP BY SdcDev.Bez
HAVING COUNT(SdcScan.ID) > 1000
ORDER BY [Queue-Länge Feedbackverarbeitung];