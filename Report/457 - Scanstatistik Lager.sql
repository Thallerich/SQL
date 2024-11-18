DECLARE @von datetime = $1$;
DECLARE @bis datetime = DATEADD(day, 1, $1$);

DROP TABLE IF EXISTS #Scans457;

SELECT Scans.ID, Scans.ActionsID, Scans.AnlageUserID_
INTO #Scans457
FROM Scans WITH(INDEX([DateTime]))
WHERE Scans.DateTime BETWEEN @von AND @bis;

SELECT Mitarbei.UserName AS Mitarbeiter,  Mitarbei.Name,
  SUM(IIF(Scans.ActionsID = 57, 1, 0)) AS "Lagerentnahme",
  SUM(IIF(Scans.ActionsID = 23, 1, 0)) AS "neu gepatcht",
  SUM(IIF(Scans.ActionsID = 49, 1, 0)) AS "Endkontrolle",
  SUM(IIF(Scans.ActionsID = 6, 1, 0)) AS "Rückgabe",
  SUM(IIF(Scans.ActionsID IN (26, 33), 1, 0)) AS "Lager",
  SUM(IIF(Scans.ActionsID = 7, 1, 0)) AS "verschrottet",
  SUM(IIF(Scans.ActionsID IN (4, 142), 1, 0)) AS "Austausch",
  COUNT(Scans.ID) AS Total
FROM #Scans457 AS Scans
RIGHT JOIN Mitarbei ON Scans.AnlageUserID_ = Mitarbei.ID
WHERE Mitarbei.MitarAbtID = 5111024  -- Mitarbeiter-Abteilung "Bekleidungsservice Lenzing"
  AND Mitarbei.Status = N'A'
GROUP BY Mitarbei.UserName, Mitarbei.Name
ORDER BY Mitarbeiter ASC;