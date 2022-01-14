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
WHERE CAST(Scans.DateTime AS date) = $1$
  AND Mitarbei.UserName IN (N'MICRORR1', N'MICRORR2', N'MICRORR3', N'MICRORR4', N'MICRORR6', N'MICROUZ1', N'MICROUZ2')
GROUP BY Mitarbei.UserName;