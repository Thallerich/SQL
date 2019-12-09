SELECT DISTINCT Mitarbei.Username AS Benutzername, Mitarbei.MitarbeiUser AS Kürzel, Mitarbei.Vorname, Mitarbei.Nachname, IIF(Standort.ID < 0, N'', Standort.Bez) AS Standort
FROM UsrInGrp
JOIN Mitarbei ON UsrInGrp.MitarbeiID = Mitarbei.ID
JOIN UserGrp ON UsrInGrp.UserGrpID = UserGrp.ID
JOIN GrpRight ON GrpRight.UserGrpID = UserGrp.ID
JOIN Rights ON GrpRight.RightsID = Rights.ID
JOIN Standort ON Mitarbei.StandortID = Standort.ID
WHERE Rights.RightsBez = N'WOZ_KdArti_Kunden_anlegen'
  AND UserGrp.UserGrpBez <> N'WOZ_SU (Admin)'
  AND Mitarbei.[Status] = N'A';