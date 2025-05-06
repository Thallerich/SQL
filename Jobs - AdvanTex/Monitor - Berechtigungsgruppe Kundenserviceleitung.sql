SELECT Mitarbei.MitarbeiUser, Mitarbei.Name, /* CAST(UsrInGrp.Anlage_ AS date) AS [hinzugefügt am], */ Gruppen = STUFF((
  SELECT DISTINCT N', ' + UserGrp.UserGrpBez + N' [' + AnlageUser.Name + N']'
  FROM UsrInGrp
  JOIN UserGrp ON UsrInGrp.UserGrpID = UserGrp.ID
  JOIN GrpRight ON GrpRight.UserGrpID = UserGrp.ID
  JOIN Mitarbei AS AnlageUser ON UsrInGrp.AnlageUserID_ = AnlageUser.ID
  WHERE UsrInGrp.MitarbeiID = Mitarbei.ID
    AND (GrpRight.RightsID = (SELECT Rights.ID FROM Rights WHERE Rights.RightsBez = '#_Kundenserviceleitung') OR GrpRight.UserGrpID = (SELECT UserGrp.ID FROM UserGrp WHERE UserGrp.UserGrpBez = '*_IT(Admin)'))
  FOR XML PATH('')
), 1, 2, '')
FROM Mitarbei
WHERE (
    EXISTS (
      SELECT UsrInGrp.*
      FROM UsrInGrp
      JOIN GrpRight ON GrpRight.UserGrpID = UsrInGrp.UserGrpID
      WHERE UsrInGrp.MitarbeiID = Mitarbei.ID
        AND GrpRight.RightsID = (SELECT Rights.ID FROM Rights WHERE Rights.RightsBez = '#_Kundenserviceleitung')
        AND UsrInGrp.Anlage_ > DATEADD(day, -1, GETDATE())
    )
    OR EXISTS (
      SELECT UsrInGrp.*
      FROM UsrInGrp
      WHERE UsrInGrp.MitarbeiID = Mitarbei.ID
        AND UsrInGrp.UserGrpID = (SELECT UserGrp.ID FROM UserGrp WHERE UserGrp.UserGrpBez = '*_IT(Admin)')
        AND UsrInGrp.Anlage_ > DATEADD(day, -1, GETDATE())
    )
  );