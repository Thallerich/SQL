IF OBJECT_ID(N'tempdb..#TmpSichtbar') IS NULL
  CREATE TABLE #TmpSichtbar (
    SichtbarID int PRIMARY KEY CLUSTERED
  );
ELSE
  DELETE FROM #TmpSichtbar;

INSERT INTO #TmpSichtbar (SichtbarID)
SELECT x.value AS SichtbarID
FROM STRING_SPLIT(N'$SICHTBARIDS$', N',') AS x;

DECLARE @fromtime datetime = CAST(CAST(CAST(N'2023-04-18' AS date) AS nchar(10)) + N' ' + N'06:00:00' AS datetime);
DECLARE @totime datetime = CAST(CAST(CAST(N'2023-04-18' AS date) AS nchar(10)) + N' ' + N'15:00:00' AS datetime);
DECLARE @sqltext nvarchar(max);

SET @sqltext = N'
SELECT Mitarbei.UserName AS Arbeitsplatz,
  SUM(CASE Scans.ZielNrID WHEN 1 THEN 1 END) AS [eingelesen],
  SUM(CASE Scans.ZielNrID WHEN 7 THEN 1 END) AS [neu gepatcht],
  SUM(CASE Scans.ZielNrID WHEN 2 THEN 1 END) AS [ausgelesen],
  SUM(CASE Scans.ZielNrID WHEN 36 THEN 1 END) AS [Teile Info],
  SUM(CASE Scans.ZielNrID WHEN 19 THEN 1 END) AS [verschrottet],
  SUM(CASE Scans.ZielNrID WHEN 37 THEN 1 END) AS [Infektionswäsche],
  SUM(CASE Scans.ZielNrID WHEN 38 THEN 1 END) AS [Falschabwurf],
  SUM(CASE Scans.ZielNrID WHEN 6 THEN 1 END) AS [Rückgabe],
  COUNT(*) AS Total
FROM Scans
JOIN EinzTeil ON Scans.EinzTeilID = EinzTeil.ID
JOIN Mitarbei ON Scans.AnlageUserID_ = Mitarbei.ID
WHERE Scans.[DateTime] BETWEEN @from AND @to
  AND Scans.ZielNrID IN (1, 2, 6, 7, 19, 36, 37, 38)
  AND Mitarbei.SichtbarID IN (SELECT SichtbarID FROM #TmpSichtbar)
  AND EinzTeil.AltenheimModus = 1
GROUP BY Mitarbei.UserName;
';

EXEC sp_executesql @sqltext, N'@from datetime, @to datetime', @fromtime, @totime;