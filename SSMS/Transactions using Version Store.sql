SELECT a.session_id, d.name, a.elapsed_time_seconds/60.00 AS elapsed_time_mins,
b.open_tran, b.status,b.program_name,  a.transaction_id, a.transaction_sequence_num
FROM sys.dm_tran_active_snapshot_database_transactions a
join sys.sysprocesses b on a.session_id = b.spid
join sys.databases d on b.dbid=d.database_id
ORDER BY elapsed_time_seconds DESC