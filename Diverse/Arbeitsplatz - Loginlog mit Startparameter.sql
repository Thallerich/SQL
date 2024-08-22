DECLARE @Computer nvarchar(50) = N'';

IF @Computer != N''
  SELECT TOP 50 ArbPlatz.ComputerName, Mitarbei.MitarbeiUser AS Benutzer, Mitarbei.UserName AS Kürzel, LoginLog.LogInZeit, LoginLog.AdvanTexVersion, REPLACE(LoginLog.StartParameter, N'/Exit=Yes /MANDANT:Salesianer', N'') AS StartParameter, LoginLog.WindowsUserName
  FROM LoginLog
  JOIN ArbPlatz ON LoginLog.ArbPlatzID = ArbPlatz.ID
  JOIN Mitarbei ON LoginLog.UserID = Mitarbei.ID
  WHERE UPPER(ArbPlatz.ComputerName) = UPPER(@Computer)
  ORDER BY LoginLog.LoginZeit DESC;

GO

DECLARE @WinUser nvarchar(50) = N'';

IF @WinUser != N''
  SELECT TOP 50 ArbPlatz.ComputerName, Mitarbei.MitarbeiUser AS Benutzer, Mitarbei.UserName AS Kürzel, LoginLog.LogInZeit, LoginLog.AdvanTexVersion, REPLACE(LoginLog.StartParameter, N'/Exit=Yes /MANDANT:Salesianer', N'') AS StartParameter, LoginLog.WindowsUserName
  FROM LoginLog
  JOIN ArbPlatz ON LoginLog.ArbPlatzID = ArbPlatz.ID
  JOIN Mitarbei ON LoginLog.UserID = Mitarbei.ID
  WHERE LOWER(LoginLog.WindowsUserName) = LOWER(@WinUser)
  ORDER BY LoginLog.LoginZeit DESC;

GO

DECLARE @AdvantexUser nvarchar(50) = N'';

IF @AdvantexUser != N''
  SELECT TOP 50 ArbPlatz.ComputerName, Mitarbei.MitarbeiUser AS Benutzer, Mitarbei.UserName AS Kürzel, Mitarbei.Name, LoginLog.LogInZeit, LoginLog.AdvanTexVersion, REPLACE(LoginLog.StartParameter, N'/Exit=Yes /MANDANT:Salesianer', N'') AS StartParameter, LoginLog.WindowsUserName
  FROM LoginLog
  JOIN ArbPlatz ON LoginLog.ArbPlatzID = ArbPlatz.ID
  JOIN Mitarbei ON LoginLog.UserID = Mitarbei.ID
  WHERE (Mitarbei.MitarbeiUser = @AdvantexUser OR Mitarbei.UserName = @AdvantexUser)
  ORDER BY LoginLog.LoginZeit DESC;

GO