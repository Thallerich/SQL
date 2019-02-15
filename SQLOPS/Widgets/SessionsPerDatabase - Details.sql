SELECT DISTINCT DB_NAME(database_id) AS DB, login_name AS [Session]
FROM sys.dm_exec_sessions
ORDER BY [DB];