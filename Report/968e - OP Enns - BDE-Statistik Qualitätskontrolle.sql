WITH DistinctScans (EinzTeilID, Datum, Zeitpunkt, AnlageUserID_)
AS (
  SELECT Scans.EinzTeilID, CAST(Scans.[DateTime] AS date) AS Datum, MIN(Scans.[DateTime]) AS Zeitpunkt, Scans.AnlageUserID_
  FROM (
    SELECT Scans.EinzTeilID, Scans.[DateTime], Scans.AnlageUserID_
    FROM Scans
    WHERE CAST(Scans.[DateTime] AS date) BETWEEN $1$ AND $2$
      AND Scans.ActionsID = 109

    UNION ALL

    SELECT OPScans.OPTeileID, OPScans.Zeitpunkt, OPScans.AnlageUserID_
    FROM Salesianer_Archive.dbo.OPScans
    WHERE CAST(OPScans.Zeitpunkt AS date) BETWEEN $1$ AND $2$
      AND OPScans.ActionsID = 109
  ) AS Scans  
  GROUP BY Scans.EinzTeilID, CAST(Scans.[DateTime] AS date), Scans.AnlageUserID_
)
SELECT Benutzername, Mitarbeiter, Datum, [5] AS [05:00], [6] AS [06:00], [7] AS [07:00], [8] AS [08:00], [9] AS [09:00], [10] AS [10:00], [11] AS [11:00], [12] AS [12:00], [13] AS [13:00], [14] AS [14:00], [15] AS [15:00], [16] AS [16:00], [17] AS [17:00], [18] AS [18:00], [19] AS [19:00], [20] AS [20:00], [21] AS [21:00], [22] AS [22:00], [23] AS [23:00], [99] AS Summe
FROM (
  SELECT ISNULL(Mitarbei.MitarbeiUser, N'Summe') AS Benutzername, Mitarbei.Name AS Mitarbeiter, DistinctScans.Datum, ISNULL(DATEPART(hour, DistinctScans.Zeitpunkt), 99) AS Stunde, COUNT(DistinctScans.EinzTeilID) AS [Anzahl Teile]
  FROM DistinctScans
  JOIN Mitarbei ON DistinctScans.AnlageUserID_ = Mitarbei.ID
  WHERE Mitarbei.StandortID IN ($3$)
  GROUP BY CUBE ((Mitarbei.MitarbeiUser, Mitarbei.Name, DistinctScans.Datum), DATEPART(hour, DistinctScans.Zeitpunkt))
) AS BDEData
PIVOT (
  SUM([Anzahl Teile])
  FOR Stunde IN ([5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [99])
) AS BDE
ORDER BY 
  CASE WHEN Benutzername = N'Summe' THEN 1 ELSE 0 END,
  Benutzername, 
  Datum;