SELECT conn.connect_time, conn.client_net_address, sess.host_name, sess.login_name, sess.[status], sess.cpu_time, sqltext.text AS [last_sql]
FROM sys.dm_exec_connections AS conn
JOIN sys.dm_exec_sessions AS sess ON conn.session_id = sess.session_id
CROSS APPLY sys.dm_exec_sql_text(conn.most_recent_sql_handle) AS sqltext