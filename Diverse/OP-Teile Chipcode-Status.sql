SELECT OpTeileID, MAX(Zeitpunkt) AS LastScan
INTO #TmpOpScans
FROM OpScans
GROUP BY 1;

UPDATE OpTeile SET OpTeile.LastScanTime = tops.LastScan
FROM OpTeile, #TmpOpScans tops
WHERE tops.OpTeileID = OpTeile.ID
  AND OpTeile.LastScanTime IS NULL; 

SELECT COUNT(OpTeile.ID) AS Anzahl, 'Verheiratet' AS Status
FROM OpTeile
WHERE OpTeile.LastScanTime >= '01.06.2011 00:00:00'
  AND OpTeile.Code2 LIKE 'E00%'
  
UNION

SELECT COUNT(OpTeile.ID) AS Anzahl, 'nicht Verheiratet' AS Status
FROM OpTeile
WHERE OpTeile.LastScanTime >= '01.06.2011 00:00:00'
  AND (OpTeile.Code2 IS NULL OR OpTeile.Code2 NOT LIKE 'E00%')
  
UNION

SELECT COUNT(OpTeile.ID) AS Anzahl, 'Teile gesamt' AS Status
FROM OpTeile
WHERE OpTeile.LastScanTime >= '01.06.2011 00:00:00';