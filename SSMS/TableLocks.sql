USE Wozabal
GO

SELECT request_lifetime, request_reference_count, request_status, request_mode, request_type, request_owner_type, login_name, program_name, host_name, login_time, OBJECT_NAME(resource_associated_entity_id) AS ResourceObject
FROM sys.dm_tran_locks
LEFT OUTER JOIN sys.dm_exec_sessions ON sys.dm_tran_locks.request_session_id = sys.dm_exec_sessions.session_id
WHERE sys.dm_tran_locks.resource_database_id = DB_ID()
  AND sys.dm_tran_locks.resource_associated_entity_id <> 0
  --AND sys.dm_tran_locks.request_lifetime > 0
  AND sys.dm_tran_locks.resource_type = 'OBJECT'
	AND sys.dm_tran_locks.resource_associated_entity_id = OBJECT_ID(N'dbo.PROD')
ORDER BY request_status DESC
GO

/*
SELECT * 
FROM sys.dm_tran_locks
WHERE sys.dm_tran_locks.resource_database_id = DB_ID()
	AND sys.dm_tran_locks.resource_associated_entity_id = OBJECT_ID(N'dbo.OPETIPO');
GO
*/