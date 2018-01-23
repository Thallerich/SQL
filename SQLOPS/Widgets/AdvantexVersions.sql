SELECT s.[Version], COUNT(s.ID) AS [Sessions]
FROM dbSystem.dbo.sessions s 
WHERE s.Mandant = DB_NAME()
  AND s.LastHeartbeat > DateAdd(Minute, -20, GETDATE())
GROUP BY s.[Version]
ORDER BY [Sessions] DESC;