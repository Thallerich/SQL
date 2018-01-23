SELECT COUNT(DISTINCT loginame + hostname) AS Logins
FROM sys.sysprocesses
WHERE dbid = DB_ID();