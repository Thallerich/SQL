SELECT Mitarbei.MitarbeiUser, Mitarbei.Name, CAST(UsrInGrp.Anlage_ AS date) AS [hinzugefügt am]
FROM UsrInGrp
JOIN Mitarbei ON UsrInGrp.MitarbeiID = Mitarbei.ID
WHERE UsrInGrp.UserGrpID IN (
    SELECT GrpRight.UserGrpID
    FROM GrpRight
    WHERE GrpRight.RightsID = (SELECT Rights.ID FROM Rights WHERE Rights.RightsBez = '#_Kundenserviceleitung')
      AND GrpRight.UserGrpID != (SELECT UserGrp.ID FROM UserGrp WHERE UserGrp.UserGrpBez = '*_IT(Admin)')
  )
  AND UsrInGrp.Anlage_ > DATEADD(day, -1, GETDATE());