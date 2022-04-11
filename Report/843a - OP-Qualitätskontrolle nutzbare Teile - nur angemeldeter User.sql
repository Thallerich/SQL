DECLARE @von datetime = $STARTDATE$;
DECLARE @bis datetime = DATEADD(day, 1, $ENDDATE$);

WITH QKTeile AS (
  SELECT Scans.EinzTeilID, Scans.AnlageUserID_ AS UserID, CAST(Scans.[DateTime] AS date) AS Datum, Scans.ActionsID, LEAD(Scans.ActionsID) OVER (PARTITION BY Scans.EinzTeilID ORDER BY Scans.[DateTime]) AS NextActionID
  FROM Scans
  JOIN ArbPlatz ON Scans.ArbPlatzID = ArbPlatz.ID
  JOIN Standort ON ArbPlatz.StandortID = Standort.ID
  WHERE Scans.[DateTime] BETWEEN @von AND @bis
    AND Standort.ID IN ($2$)
)
SELECT QKPivot.Datum, QKPivot.Name AS Mitarbeiter, [109] AS [Qualitätskontrolle OK], [105] AS Nachwäsche, [108] AS Schrott
FROM (
  SELECT QKTeile.EinzTeilID,
    QKTeile.Datum,
    Mitarbei.Name,
    ActionID =
      CASE QKTeile.NextActionID
        WHEN 105 THEN 105
        WHEN 108 THEN 108
        ELSE 109
      END
  FROM QKTeile
  JOIN Mitarbei ON QKTeile.UserID = Mitarbei.ID
  WHERE QKTeile.ActionsID = 109
    AND QKTeile.UserID = (SELECT MitarbeiID FROM #AdvSession)
) AS QKPivotDaten
PIVOT (
  COUNT(QKPivotDaten.EinzTeilID)
  FOR ActionID IN ([109], [105], [108])
) AS QKPivot;