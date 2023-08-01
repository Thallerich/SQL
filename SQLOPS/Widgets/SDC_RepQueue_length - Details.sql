SELECT SdcDev.Bez AS [von Sortieranlage], COUNT(SdcScan.ID) AS [Queue-Länge]
FROM SdcScan
JOIN SdcDev ON SdcScan.SdcDevID = SdcDev.ID
GROUP BY SdcDev.Bez