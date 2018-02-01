SELECT s.Mandant, FORMAT(s.Startzeit, N'G', N'de-AT') AS Startzeit, s.DBLoginName AS DomainUser, m.MitarbeiUser AS AdvanTexUser, alm.ComputerName, s.[Version] AS AdvanTexVersion, FORMAT(s.LastHeartBeat, N'G', N'de-AT') AS LastHeartbeat, ISNULL(s.OnlyAufruf, N'') AS OnlyAufruf
FROM dbSystem.dbo.sessions s 
LEFT OUTER JOIN Mitarbei m ON m.ID = s.MitarbeiID 
LEFT OUTER JOIN ArbPlatz alm ON alm.ID = s.ArbPlatzID 
WHERE s.Mandant = DB_NAME()
  AND s.LastHeartbeat > DateAdd(Minute, -20, GETDATE())
ORDER BY Version ASC;