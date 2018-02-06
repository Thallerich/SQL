SELECT ChipcodePrefix, StatusBez AS Teilestatus, [7] AS [Scan <= 7], [14] AS [Scans <= 14], [30] AS [Scan <= 30], [60] AS [Scan <= 60], [90] AS [Scan <= 90], [180] AS [Scan <= 180], [360] AS [Scan <= 360], [9000] AS [Scan > 360]
FROM (
  SELECT LEFT(OPTeile.Code, 5) AS ChipcodePrefix, [Status].StatusBez, COUNT(OPTeile.ID) AS Amount, DaysSinceLastScan = 
    CASE
      WHEN DATEDIFF(day, OPTeile.LastScanTime, GETDATE()) <= 7 THEN 7
      WHEN DATEDIFF(day, OPTeile.LastScanTime, GETDATE()) BETWEEN 8 AND 14 THEN 14
      WHEN DATEDIFF(day, OPTeile.LastScanTime, GETDATE()) BETWEEN 15 AND 30 THEN 30
      WHEN DATEDIFF(day, OPTeile.LastScanTime, GETDATE()) BETWEEN 31 AND 60 THEN 60
      WHEN DATEDIFF(day, OPTeile.LastScanTime, GETDATE()) BETWEEN 61 AND 90 THEN 90
      WHEN DATEDIFF(day, OPTeile.LastScanTime, GETDATE()) BETWEEN 91 AND 180 THEN 180
      WHEN DATEDIFF(day, OPTeile.LastScanTime, GETDATE()) BETWEEN 181 AND 360 THEN 360
      ELSE 9000  -- it's never over 9000! :)
    END
  FROM OPTeile
  JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
  JOIN [Status] ON OPTeile.[Status] = [Status].[Status] AND [Status].Tabelle = N'OPTEILE'
  WHERE Artikel.EAN IS NOT NULL
    AND LEN(OPTeile.Code) = 24
  GROUP BY LEFT(OPTeile.Code, 5), [Status].[StatusBez],
    CASE
      WHEN DATEDIFF(day, OPTeile.LastScanTime, GETDATE()) <= 7 THEN 7
      WHEN DATEDIFF(day, OPTeile.LastScanTime, GETDATE()) BETWEEN 8 AND 14 THEN 14
      WHEN DATEDIFF(day, OPTeile.LastScanTime, GETDATE()) BETWEEN 15 AND 30 THEN 30
      WHEN DATEDIFF(day, OPTeile.LastScanTime, GETDATE()) BETWEEN 31 AND 60 THEN 60
      WHEN DATEDIFF(day, OPTeile.LastScanTime, GETDATE()) BETWEEN 61 AND 90 THEN 90
      WHEN DATEDIFF(day, OPTeile.LastScanTime, GETDATE()) BETWEEN 91 AND 180 THEN 180
      WHEN DATEDIFF(day, OPTeile.LastScanTime, GETDATE()) BETWEEN 181 AND 360 THEN 360
      ELSE 9000  -- it's never over 9000! :)
    END
) AS Chipdaten
PIVOT (
  SUM(Amount)
  FOR DaysSinceLastScan IN ([7], [14], [30], [60], [90], [180], [360], [9000])
) AS ChipPivot
ORDER BY ChipcodePrefix, Teilestatus;