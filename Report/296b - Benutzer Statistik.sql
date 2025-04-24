/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Prepare data                                                                                                              ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

IF OBJECT_ID(N'tempdb..#TmpResult296') IS NULL
  CREATE TABLE #TmpResult296 (
    Arbeitsplatz nvarchar(8) COLLATE Latin1_General_CS_AS,
    Eingelesen int NOT NULL DEFAULT 0,
    Gepatcht int NOT NULL DEFAULT 0,
    Ausgelesen int NOT NULL DEFAULT 0,
    Schrott int NOT NULL DEFAULT 0,
    Infektion int NOT NULL DEFAULT 0,
    Falsch int NOT NULL DEFAULT 0,
    Rückgabe int NOT NULL DEFAULT 0,
    Gesamt int NOT NULL DEFAULT 0
  );
ELSE
  DELETE FROM #TmpResult296;

DECLARE @fromtime datetime2 = CAST($1$ AS datetime2);
DECLARE @totime datetime2 = CAST(DATEADD(day, 1, $2$) AS datetime2);
DECLARE @sqltext nvarchar(max);

SET @sqltext = N'
INSERT INTO #TmpResult296 (Arbeitsplatz, Eingelesen, Gepatcht, Ausgelesen, Schrott, Infektion, Falsch, Rückgabe, Gesamt)
SELECT Mitarbei.UserName AS Arbeitsplatz,
  ISNULL(SUM(IIF(Scans.ActionsID = 1, 1, 0)), 0) AS [eingelesen],
  ISNULL(SUM(IIF(Scans.ActionsID = 23, 1, 0)), 0) AS [neu gepatcht],
  ISNULL(SUM(IIF(Scans.ActionsID = 2, 1, 0)), 0) AS [ausgelesen],
  ISNULL(SUM(IIF(Scans.ActionsID = 7, 1, 0)), 0) AS [verschrottet],
  ISNULL(SUM(IIF(Scans.ActionsID = 144, 1, 0)), 0) AS [Infektionswäsche],
  ISNULL(SUM(IIF(Scans.ActionsID = 52, 1, 0)), 0) AS [Falschabwurf],
  ISNULL(SUM(IIF(Scans.ActionsID = 6, 1, 0)), 0) AS [Rückgabe],
  COUNT(*) AS Total
FROM Scans
JOIN EinzTeil ON Scans.EinzTeilID = EinzTeil.ID
JOIN Mitarbei ON Scans.AnlageUserID_ = Mitarbei.ID
WHERE Scans.[DateTime] BETWEEN @from AND @to
  AND Scans.ActionsID IN (1, 2, 6, 7, 23, 52, 144)
  AND Mitarbei.SichtbarID IN (SELECT SichtbarID FROM #SichtbarIdListe)
GROUP BY Mitarbei.UserName;
';

EXEC sp_executesql @sqltext, N'@from datetime, @to datetime', @fromtime, @totime;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Reporting                                                                                                                 ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Arbeitsplatz, Eingelesen AS eingelesen, Gepatcht AS [neu gepatcht], Ausgelesen AS ausgelesen, Schrott AS [verschrottet], Infektion AS Infektionswäsche, Falsch AS Falschabwurf, Rückgabe, Gesamt AS Total
FROM #TmpResult296;