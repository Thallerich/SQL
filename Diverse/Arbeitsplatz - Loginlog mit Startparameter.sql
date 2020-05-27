DECLARE @Computer nvarchar(50) = N'LEMICRORR06';

SELECT TOP 50 ArbPlatz.ComputerName, Mitarbei.UserName, LoginLog.LogInZeit, LoginLog.AdvanTexVersion, LoginLog.StartParameter
FROM LoginLog
JOIN ArbPlatz ON LoginLog.ArbPlatzID = ArbPlatz.ID
JOIN Mitarbei ON LoginLog.UserID = Mitarbei.ID
WHERE ArbPlatz.ComputerName = @Computer
ORDER BY LoginLog.LoginZeit DESC;