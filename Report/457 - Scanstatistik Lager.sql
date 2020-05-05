DECLARE @von datetime = $1$;
DECLARE @bis datetime = DATEADD(day, 1, $1$);

DROP TABLE IF EXISTS #Scans457;

SELECT *
INTO #Scans457
FROM Scans
WHERE Scans.DateTime BETWEEN @von AND @bis;

SELECT Mitarbei.UserName AS Mitarbeiter,  Mitarbei.Name,
  SUM(IIF(Scans.ZielNrID = 40, 1, 0)) AS "Lagerentnahme",
  SUM(IIF(Scans.ZielNrID = 7, 1, 0)) AS "neu gepatcht",
  SUM(IIF(Scans.ZielNrID = 41, 1, 0)) AS "Endkontrolle",
  SUM(IIF(Scans.ZielNrID = 6, 1, 0)) AS "Rückgabe",
  SUM(IIF(Scans.ZielNrID = 18, 1, 0)) AS "Lager",
  SUM(IIF(Scans.ZielNrID = 19, 1, 0)) AS "verschrottet",
  SUM(IIF(Scans.ZielNrID = 5, 1, 0)) AS "Austausch",
  SUM(IIF(Scans.ZielNrID = 36, 1, 0)) AS "Teile Info",
  COUNT(Scans.ID) AS Total
FROM #Scans457 AS Scans
RIGHT JOIN Mitarbei ON Scans.AnlageUserID_ = Mitarbei.ID
WHERE Mitarbei.MitarAbtID = 5111024  -- Mitarbeiter-Abteilung "Bekleidungsservice Lenzing"
  AND Mitarbei.Status = N'A'
GROUP BY Mitarbei.UserName, Mitarbei.Name
ORDER BY Mitarbeiter ASC;