SELECT Mitarbei.ID AS MitarbeiID,
  Mitarbei.Initialen,
  Firma.Bez AS Firma,
  Standort.Bez AS Standort,
  Mitarbei.MitarbeiUser AS [Username],
  Mitarbei.Vorname,
  Mitarbei.Nachname,
  Mitarbei.LastLogin,
  [deaktivieren] = CAST(IIF((Mitarbei.LastLogin < N'2025-01-01 00:00:00' OR Mitarbei.LastLogin IS NULL) AND NOT EXISTS (SELECT UsrInGrp.* FROM UsrInGrp WHERE UsrInGrp.MitarbeiID = Mitarbei.ID AND UsrInGrp.UserGrpID IN (SELECT UserGrp.ID FROM UserGrp WHERE UserGrp.UserGrpBez IN (N'SAL_SDC', N'SAL_ADVSUP_only'))), 1, 0) AS bit),
  [kein Standort] = CAST(IIF(Mitarbei.StandortID < 0, 1, 0) AS bit),
  [keine Firma] = CAST(IIF(Mitarbei.FirmaID < 0, 1, 0) AS bit)
FROM Mitarbei
JOIN Standort ON Mitarbei.StandortID = Standort.ID
JOIN Firma ON Mitarbei.FirmaID = Firma.ID
WHERE Mitarbei.[Status] = N'A'
  AND Mitarbei.IsAdvanTexUser = 1
  AND (Mitarbei.LastLogin < N'2025-01-01 00:00:00' OR Mitarbei.LastLogin IS NULL OR Mitarbei.StandortID < 0 OR Mitarbei.FirmaID < 0)