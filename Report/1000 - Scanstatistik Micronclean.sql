SELECT Mitarbei.UserName AS Arbeitsplatz,
  SUM(CASE Scans.ZielNrID WHEN 2 THEN 1 END) AS N'Auslesen RR',
  SUM(CASE Scans.ZielNrID WHEN 1 THEN 1 END) AS N'Einlesen Unrein',
  SUM(CASE Scans.ZielNrID WHEN 41 THEN 1 END) AS N'Endkontrolle',
  SUM(CASE Scans.ZielNrID WHEN 6 THEN 1 END) AS N'Rückgabe',
  SUM(CASE Scans.ZielNrID WHEN 18 THEN 1 END) AS N'Lager',
  SUM(CASE Scans.ZielNrID WHEN 19 THEN 1 END) AS N'verschrottet',
  SUM(CASE Scans.ZielNrID WHEN 5 THEN 1 END) AS N'Austausch',
  SUM(CASE Scans.ZielNrID WHEN 36 THEN 1 END) AS N'Teile Info',
  COUNT(Scans.ID) AS Total
FROM Scans
LEFT OUTER JOIN Mitarbei ON Scans.AnlageUserID_ = Mitarbei.ID
WHERE CONVERT(date, Scans.DateTime) = $1$
  AND Mitarbei.UserName IN (N'RHOF', N'MICRORR1', N'MICR0RR2', N'MICR0RR3', N'MICR0RR4', N'MICR0RR6','MICROUZ0', N'MICROUZ2')
GROUP BY Mitarbei.UserName;