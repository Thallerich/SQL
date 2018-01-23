SELECT s.Mandant, FORMAT(s.Startzeit, N'G', N'de-AT'), s.DBLoginName AS DomainUser, m.MitarbeiUser AS AdvanTexUser, alm.ComputerName, s.[Version] AS AdvanTexVersion, FORMAT(s.LastHeartBeat, N'G', N'de-AT') AS LastHeartbeat, s.OnlyAufruf
FROM dbSystem.dbo.sessions s 
LEFT OUTER JOIN Mitarbei m ON m.ID = s.MitarbeiID 
LEFT OUTER JOIN ArbPlatz alm ON alm.ID = s.ArbPlatzID 
WHERE s.Mandant = DB_NAME()
ORDER BY Version ASC;