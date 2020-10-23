WITH CTE_Loginlog AS (
  SELECT UPPER(LoginLog.WindowsUserName) AS WindowsUserName, REPLACE(LoginLog.StartParameter, N'/Exit=Yes /Mandant:Wozabal', N'') AS StartParameter, COUNT(LoginLog.ID) AS [Anzahl Logins], MAX(LoginLog.LogInZeit) AS LastLogin
  FROM LoginLog
  WHERE LoginLog.LogInZeit >= N'2020-06-01'
    AND LoginLog.WindowsUserName NOT IN (N'advantexadmin')
  GROUP BY UPPER(LoginLog.WindowsUserName), REPLACE(LoginLog.StartParameter, N'/Exit=Yes /Mandant:Wozabal', N'')
)
SELECT CTE_Loginlog.WindowsUserName, CTE_LoginLog.[Anzahl Logins], CTE_Loginlog.LastLogin, N'AdvanTex' AS DisplayName, N'"\\salctxfil1.salres.com\citrix$\Applications\Advantex\Apps\Loader\Loader.exe" ' + CTE_LoginLog.StartParameter AS LoaderCall, N'\\salctxfil1.salres.com\citrix$\Applications\Advantex\Apps\Loader' AS WorkingDirectory
FROM CTE_LoginLog
ORDER BY CTE_Loginlog.WindowsUserName ASC, CTE_Loginlog.[Anzahl Logins] DESC;