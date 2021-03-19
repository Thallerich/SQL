WITH Fahrzeugstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'FAHRZEUG')
),
Tourenstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TOUREN')
),
Fahrerstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'MITARBEI')
)
SELECT Touren.Tour,
  Touren.Bez AS [Tour-Bezeichnung],
  Wochentag = 
    CASE Touren.Wochentag
      WHEN N'1' THEN N'Montag'
      WHEN N'2' THEN N'Dienstag'
      WHEN N'3' THEN N'Mittwoch'
      WHEN N'4' THEN N'Donnerstag'
      WHEN N'5' THEN N'Freitag'
      WHEN N'6' THEN N'Samstag'
      WHEN N'7' THEN N'Sonntag'
      ELSE N'Fehler - kein Wochentag definiert'
    END,
  Tourenstatus.StatusBez AS [Tour-Status],
  Fahrzeug.Kennzeichen,
  Fahrzeug.Typ AS [Fahrzeug-Typ],
  Fahrzeugstatus.StatusBez AS [Fahrzeug-Status],
  Mitarbei.Name AS Fahrer,
  Fahrerstatus.StatusBez AS [Fahrer-Status],
  Sichtbar.Bez AS [Sichtbarkeit Tour],
  Standort.SuchCode AS [Expeditions-Standort]
FROM Touren
JOIN Tourenstatus ON Touren.Status = Tourenstatus.Status
JOIN Fahrzeug ON Touren.FahrzeugID = Fahrzeug.ID
JOIN Fahrzeugstatus ON Fahrzeug.Status = Fahrzeugstatus.Status
JOIN Mitarbei ON Touren.MitarbeiID = Mitarbei.ID
JOIN Fahrerstatus ON Mitarbei.Status = Fahrerstatus.Status
JOIN Sichtbar ON Touren.SichtbarID = Sichtbar.ID
JOIN Standort ON Touren.ExpeditionID = Standort.ID
WHERE Touren.ID > 0
  AND (($1$ = 1 AND Touren.Status = N'A') OR $1$ = 0)
  AND Touren.SichtbarID IN ($SICHTBARIDS$)
ORDER BY Touren.Tour ASC;