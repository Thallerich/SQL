DECLARE @Computer nvarchar(50) = N'UHF-EN-2114009';
DECLARE @WinUser nvarchar(50) = N'TL_Metrik-FWGP';

SELECT TOP 50 ArbPlatz.ComputerName, Mitarbei.UserName, LoginLog.LogInZeit, LoginLog.AdvanTexVersion, LoginLog.StartParameter, LoginLog.WindowsUserName
FROM LoginLog
JOIN ArbPlatz ON LoginLog.ArbPlatzID = ArbPlatz.ID
JOIN Mitarbei ON LoginLog.UserID = Mitarbei.ID
WHERE UPPER(ArbPlatz.ComputerName) = UPPER(@Computer)
ORDER BY LoginLog.LoginZeit DESC;

SELECT TOP 50 ArbPlatz.ComputerName, Mitarbei.UserName, LoginLog.LogInZeit, LoginLog.AdvanTexVersion, LoginLog.StartParameter, LoginLog.WindowsUserName
FROM LoginLog
JOIN ArbPlatz ON LoginLog.ArbPlatzID = ArbPlatz.ID
JOIN Mitarbei ON LoginLog.UserID = Mitarbei.ID
WHERE LOWER(LoginLog.WindowsUserName) = LOWER(@WinUser)
ORDER BY LoginLog.LoginZeit DESC;