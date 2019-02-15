SELECT DB_NAME(database_id) AS DB, COUNT(DISTINCT login_name) AS [Sessions]
FROM sys.dm_exec_sessions
GROUP BY DB_NAME(database_id)
ORDER BY DB ASC;