SELECT Mitarbei.ID AS MitarbeiID,
  Mitarbei.Initialen,
  Mitarbei.MitarbeiUser AS [Username],
  Mitarbei.Vorname,
  Mitarbei.Nachname,
  Mitarbei.LastLogin,
  [deaktivieren] = CAST(IIF((Mitarbei.LastLogin < N'2025-01-01 00:00:00' OR Mitarbei.LastLogin IS NULL), 1, 0) AS bit),
  [kein Standort] = CAST(IIF(Mitarbei.StandortID < 0, 1, 0) AS bit),
  [keine Firma] = CAST(IIF(Mitarbei.FirmaID < 0, 1, 0) AS bit)
FROM Mitarbei
JOIN Standort ON Mitarbei.StandortID = Standort.ID
JOIN Firma ON Mitarbei.FirmaID = Firma.ID
WHERE Mitarbei.[Status] = N'A'
  AND Mitarbei.IsAdvanTexUser = 1
  AND (Mitarbei.LastLogin < N'2025-01-01 00:00:00' OR Mitarbei.LastLogin IS NULL OR Mitarbei.StandortID < 0 OR Mitarbei.FirmaID < 0)