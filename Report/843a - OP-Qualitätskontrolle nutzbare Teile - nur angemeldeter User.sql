DECLARE @von datetime = $STARTDATE$;
DECLARE @bis datetime = DATEADD(day, 1, $ENDDATE$);

WITH QKTeile AS (
  SELECT OPScans.OPTeileID, OPScans.AnlageUserID_ AS UserID, CAST(OPScans.Zeitpunkt AS date) AS Datum, OPScans.ActionsID, LEAD(OPScans.ActionsID) OVER (PARTITION BY OPScans.OPTeileID ORDER BY OPScans.Zeitpunkt) AS NextActionID
  FROM OPScans
  JOIN ArbPlatz ON OPScans.ArbPlatzID = ArbPlatz.ID
  JOIN Standort ON ArbPlatz.StandortID = Standort.ID
  WHERE OPScans.Zeitpunkt BETWEEN @von AND @bis
    AND Standort.ID IN ($2$)
)
SELECT QKPivot.Datum, QKPivot.Name AS Mitarbeiter, [109] AS [Qualitätskontrolle OK], [105] AS Nachwäsche, [108] AS Schrott
FROM (
  SELECT QKTeile.OPTeileID,
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
  COUNT(QKPivotDaten.OPTeileID)
  FOR ActionID IN ([109], [105], [108])
) AS QKPivot;