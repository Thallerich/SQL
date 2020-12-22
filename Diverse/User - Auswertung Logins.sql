SELECT DISTINCT Mitarbei.UserName AS [UserName AdvanTex], Mitarbei.Name AS Mitarbeiter, ArbPlatz.ComputerName AS Computername, LoginLog.WindowsUserName AS [Windows-User]
FROM LoginLog
JOIN ArbPlatz ON LoginLog.ArbPlatzID = ArbPlatz.ID
JOIN Mitarbei ON LoginLog.UserID = Mitarbei.ID
WHERE LoginLog.LogInZeit > N'2020-11-30 00:00:00'
  AND LoginLog.WindowsUserName != N'svc_AdvantexAdmin';