SELECT st.session_id, se.host_name, se.nt_user_name, se.login_time, DB_NAME(dt.database_id) AS database_name , CASE WHEN dt.database_transaction_begin_time IS NULL THEN 'read-only' ELSE 'read-write' END AS transaction_state , dt.database_transaction_begin_time AS read_write_start_time , dt.database_transaction_log_record_count , dt.database_transaction_log_bytes_used
FROM sys.dm_tran_session_transactions AS st 
INNER JOIN sys.dm_tran_database_transactions AS dt ON st.transaction_id = dt.transaction_id 
INNER JOIN sys.dm_exec_sessions AS se ON st.session_id = se.session_id
ORDER BY st.session_id , database_name;
GO