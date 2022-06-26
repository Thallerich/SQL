SELECT process.session_id, process.blocking_session_id, process.start_time, session.program_name, session.host_name, session.login_name, session.login_time, db.name, process.status, process.percent_complete, process.command, sqltext.text, DATEADD(minute, process.estimated_completion_time / (1000 * 60), GETDATE()) AS ETA
FROM sys.databases db, sys.dm_exec_sessions session, sys.dm_exec_requests process
CROSS APPLY sys.dm_exec_sql_text(process.sql_handle) sqltext
WHERE process.database_id = db.database_id
  AND process.session_id = session.session_id
  AND process.status not in ('sleeping')
--  AND process.cmd not in ('AWAITING COMMAND', 'MIRROR HANDLER', 'LAZY WRITER', 'CHECKPOINT SLEEP', 'RA MANAGER')
ORDER BY process.start_time;