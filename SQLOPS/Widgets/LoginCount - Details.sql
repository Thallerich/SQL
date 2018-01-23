SELECT DISTINCT sys.sysprocesses.hostname, sys.sysprocesses.loginame, sys.sysprocesses.login_time, sys.sysprocesses.program_name, sys.sysprocesses.nt_username, sys.sysprocesses.[status]
FROM sys.sysprocesses
WHERE dbid = DB_ID()
ORDER BY hostname, loginame, program_name;