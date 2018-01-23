DECLARE @von datetime;
DECLARE @bis datetime;

DROP TABLE IF EXISTS #TempScans296;

SET @von = CONVERT(datetime, CONVERT(nchar(10), $1$) + ' ' + $2$);
SET @bis = CONVERT(datetime, CONVERT(nchar(10), $1$) + ' ' + $3$);

SELECT Scans.* 
INTO #TempScans296 
FROM Scans 
WHERE Scans.DateTime BETWEEN @von AND @bis;

SELECT Mitarbei.UserName as Arbeitsplatz,
  SUM(CASE ZielNrID WHEN 1 THEN 1 END) as [eingelesen],
  SUM(CASE ZielNrID WHEN 7 THEN 1 END) as [neu gepatcht],
  SUM(CASE ZielNrID WHEN 2 THEN 1 END) as [ausgelesen],
  SUM(CASE ZielNrID WHEN 36 THEN 1 END) as [Teile Info],
  SUM(CASE ZielNrID WHEN 19 THEN 1 END) as [verschrottet],
  SUM(CASE ZielNrID WHEN 37 THEN 1 END) as [Infektionswäsche],
  SUM(CASE ZielNrID WHEN 38 THEN 1 END) as [Falschabwurf],
  SUM(CASE ZielNrID WHEN 6 THEN 1 END) as [Rückgabe],
  COUNT(*) as Total
FROM #TempScans296 AS Scans
JOIN Mitarbei ON Scans.AnlageUserID_ = Mitarbei.ID
GROUP BY Mitarbei.UserName;