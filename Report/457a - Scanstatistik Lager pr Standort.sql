DECLARE @von datetime2 = CAST($STARTDATE$ AS datetime2);
DECLARE @bis datetime2 = DATEADD(day, 1, CAST($ENDDATE$ AS datetime2));  /* Um den Ende-Tag noch vollständig in der Auswertung zu haben muss einen Tag weitergerechnet werden! */

DROP TABLE IF EXISTS #Scans457b;

SELECT Scans.ID, Scans.ActionsID, Scans.AnlageUserID_
INTO #Scans457b
FROM Scans WITH (INDEX([DateTime]))
WHERE Scans.DateTime BETWEEN @von AND @bis
  AND Scans.ActionsID IN (57, 23, 49, 6, 26, 33, 7, 4, 142, 176, 167, 76);

SELECT Standort.Suchcode, MitarAbt.MitarAbtBez, Mitarbei.UserName AS Mitarbeiter,  Mitarbei.Name,
  SUM(IIF(Scans.ActionsID = 57, 1, 0)) AS "Lagerentnahme",
  SUM(IIF(Scans.ActionsID = 23, 1, 0)) AS "neu gepatcht",
  SUM(IIF(Scans.ActionsID = 49, 1, 0)) AS "Endkontrolle",
  SUM(IIF(Scans.ActionsID = 6, 1, 0)) AS "Rückgabe",
  SUM(IIF(Scans.ActionsID IN (26, 33, 76), 1, 0)) AS "Lager",
  SUM(IIF(Scans.ActionsID = 7, 1, 0)) AS "verschrottet",
  SUM(IIF(Scans.ActionsID IN (4, 142), 1, 0)) AS "Austausch",
  SUM(IIF(Scans.ActionsID = 176, 1, 0)) AS "Näherei",
  SUM(IIF(Scans.ActionsID = 167, 1, 0)) AS "Inventurbuchung",  
  COUNT(Scans.ID) AS Total
FROM #Scans457b AS Scans
JOIN Mitarbei ON Scans.AnlageUserID_ = Mitarbei.ID
JOIN Standort ON Mitarbei.StandortID = Standort.ID
JOIN MitarAbt ON Mitarbei.MitarAbtID = MitarAbt.ID
WHERE Mitarbei.Status = N'A'
  AND Standort.ID IN ($2$)
GROUP BY Standort.Suchcode, MitarAbt.MitarAbtBez, Mitarbei.UserName, Mitarbei.Name
ORDER BY Mitarbeiter ASC;