SELECT Touren.Tour,
  Touren.Bez AS [Tour-Bezeichnung],
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.VsaNr AS [VSA-Nr],
  Vsa.Bez AS [VSA-Bezeichnung],
  Lieferscheine = STUFF((
      SELECT DISTINCT N', ' + CAST(LsKo.LsNr AS nvarchar)
      FROM LsKo
      WHERE LsKo.FahrtID = Fahrt.ID
        AND LsKo.VsaID = Vsa.ID
      FOR XML PATH (N'')
    ), 1, 2, N''),
  Fahrt.PlanDatum AS Lieferdatum,
  History.Memo AS [Information durch Fahrer],
  History.Zeitpunkt AS Erfassungszeitpunkt,
  Mitarbei.Name AS Fahrer
FROM History
JOIN Vsa ON History.TableID = Vsa.ID AND History.TableName = N'VSA'
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Fahrt ON History.FahrtID = Fahrt.ID
JOIN Touren ON Fahrt.TourenID = Touren.ID
JOIN HistKat ON History.HistKatID = HistKat.ID
JOIN Mitarbei ON History.MitarbeiID = Mitarbei.ID
WHERE HistKat.CreateOnPDA = 1
  AND History.FahrtID > 0
  AND Fahrt.PlanDatum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Touren.ExpeditionID IN ($2$);