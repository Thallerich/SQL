/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Prepare data                                                                                                              ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

IF OBJECT_ID(N'tempdb..#TmpSichtbar') IS NULL
  CREATE TABLE #TmpSichtbar (
    SichtbarID int PRIMARY KEY CLUSTERED
  );
ELSE
  DELETE FROM #TmpSichtbar;

IF OBJECT_ID(N'tempdb..#TmpResult296') IS NULL
  CREATE TABLE #TmpResult296 (
    Arbeitsplatz nvarchar(8) COLLATE Latin1_General_CS_AS,
    Eingelesen int NOT NULL DEFAULT 0,
    Gepatcht int NOT NULL DEFAULT 0,
    Ausgelesen int NOT NULL DEFAULT 0,
    Info int NOT NULL DEFAULT 0,
    Schrott int NOT NULL DEFAULT 0,
    Infektion int NOT NULL DEFAULT 0,
    Falsch int NOT NULL DEFAULT 0,
    Rückgabe int NOT NULL DEFAULT 0,
    Gesamt int NOT NULL DEFAULT 0
  );
ELSE
  DELETE FROM #TmpResult296;

INSERT INTO #TmpSichtbar (SichtbarID)
SELECT x.value AS SichtbarID
FROM STRING_SPLIT(N'$SICHTBARIDS$', N',') AS x;

DECLARE @fromtime datetime = CAST(CAST(CAST(N'2023-04-18' AS date) AS nchar(10)) + N' ' + N'06:00:00' AS datetime);
DECLARE @totime datetime = CAST(CAST(CAST(N'2023-04-18' AS date) AS nchar(10)) + N' ' + N'15:00:00' AS datetime);
DECLARE @sqltext nvarchar(max);

SET @sqltext = N'
INSERT INTO #TmpResult296 (Arbeitsplatz, Eingelesen, Gepatcht, Ausgelesen, Info, Schrott, Infektion, Falsch, Rückgabe, Gesamt)
SELECT Mitarbei.UserName AS Arbeitsplatz,
  ISNULL(SUM(CASE Scans.ZielNrID WHEN 1 THEN 1 END), 0) AS [eingelesen],
  ISNULL(SUM(CASE Scans.ZielNrID WHEN 7 THEN 1 END), 0) AS [neu gepatcht],
  ISNULL(SUM(CASE Scans.ZielNrID WHEN 2 THEN 1 END), 0) AS [ausgelesen],
  ISNULL(SUM(CASE Scans.ZielNrID WHEN 36 THEN 1 END), 0) AS [Teile Info],
  ISNULL(SUM(CASE Scans.ZielNrID WHEN 19 THEN 1 END), 0) AS [verschrottet],
  ISNULL(SUM(CASE Scans.ZielNrID WHEN 37 THEN 1 END), 0) AS [Infektionswäsche],
  ISNULL(SUM(CASE Scans.ZielNrID WHEN 38 THEN 1 END), 0) AS [Falschabwurf],
  ISNULL(SUM(CASE Scans.ZielNrID WHEN 6 THEN 1 END), 0) AS [Rückgabe],
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

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Reporting                                                                                                                 ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Arbeitsplatz, Eingelesen AS eingelesen, Gepatcht AS [neu gepatcht], Ausgelesen AS ausgelesen, Info AS [Teile Info], Schrott AS [verschrottet], Infektion AS Infektionswäsche, Falsch AS Falschabwurf, Rückgabe, Gesamt AS Total
FROM #TmpResult296;