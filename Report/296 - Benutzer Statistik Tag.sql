DECLARE @fromtime datetime = CAST(CAST(CAST(N'2023-04-18' AS date) AS nchar(10)) + N' ' + N'06:00:00' AS datetime);
DECLARE @totime datetime = CAST(CAST(CAST(N'2023-04-18' AS date) AS nchar(10)) + N' ' + N'15:00:00' AS datetime);
DECLARE @sqltext nvarchar(max);

SET @sqltext = N'
SELECT Mitarbei.UserName AS Arbeitsplatz,
  SUM(CASE ZielNrID WHEN 1 THEN 1 END) AS [eingelesen],
  SUM(CASE ZielNrID WHEN 7 THEN 1 END) AS [neu gepatcht],
  SUM(CASE ZielNrID WHEN 2 THEN 1 END) AS [ausgelesen],
  SUM(CASE ZielNrID WHEN 36 THEN 1 END) AS [Teile Info],
  SUM(CASE ZielNrID WHEN 19 THEN 1 END) AS [verschrottet],
  SUM(CASE ZielNrID WHEN 37 THEN 1 END) AS [Infektionswäsche],
  SUM(CASE ZielNrID WHEN 38 THEN 1 END) AS [Falschabwurf],
  SUM(CASE ZielNrID WHEN 6 THEN 1 END) AS [Rückgabe],
  COUNT(*) AS Total
FROM Scans
JOIN Mitarbei ON Scans.AnlageUserID_ = Mitarbei.ID
WHERE Scans.[DateTime] BETWEEN @from AND @to
  AND Scans.ZielNrID IN (1, 2, 6, 7, 19, 36, 37, 38)
GROUP BY Mitarbei.UserName;
';

EXEC sp_executesql @sqltext, N'@from datetime, @to datetime', @fromtime, @totime;