DECLARE @Computer nvarchar(50) = N'sawrpc126';
DECLARE @WinUser nvarchar(50) = N'TL_Metrik-FWGP';

SELECT TOP 50 ArbPlatz.ComputerName, Mitarbei.UserName, LoginLog.LogInZeit, LoginLog.AdvanTexVersion, REPLACE(LoginLog.StartParameter, N'/Exit=Yes /MANDANT:Salesianer', N'') AS StartParameter, LoginLog.WindowsUserName
FROM LoginLog
JOIN ArbPlatz ON LoginLog.ArbPlatzID = ArbPlatz.ID
JOIN Mitarbei ON LoginLog.UserID = Mitarbei.ID
WHERE UPPER(ArbPlatz.ComputerName) = UPPER(@Computer)
ORDER BY LoginLog.LoginZeit DESC;

SELECT TOP 50 ArbPlatz.ComputerName, Mitarbei.UserName, LoginLog.LogInZeit, LoginLog.AdvanTexVersion, REPLACE(LoginLog.StartParameter, N'/Exit=Yes /MANDANT:Salesianer', N'') AS StartParameter, LoginLog.WindowsUserName
FROM LoginLog
JOIN ArbPlatz ON LoginLog.ArbPlatzID = ArbPlatz.ID
JOIN Mitarbei ON LoginLog.UserID = Mitarbei.ID
WHERE LOWER(LoginLog.WindowsUserName) = LOWER(@WinUser)
ORDER BY LoginLog.LoginZeit DESC;