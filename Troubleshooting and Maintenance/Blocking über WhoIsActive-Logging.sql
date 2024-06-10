SELECT TOP 100 DENSE_RANK() OVER (ORDER BY WhoIsActive.collection_time) AS GroupNr, WhoIsActive.collection_time, WhoIsActive.session_id, WhoIsActive.blocking_session_id, WhoIsActive.sql_text, WhoIsActive.sql_command, WhoIsActive.wait_info, REPLACE(SUBSTRING(WhoIsActive.wait_info, 2, CHARINDEX(N')', WhoIsActive.wait_info, 1) - 2), N'ms', N'') AS wait_time, WhoIsActive.login_name, WhoIsActive.status, WhoIsActive.tran_start_time, WhoIsActive.host_name, WhoIsActive.database_name, WhoIsActive.program_name, WhoIsActive.start_time
FROM Salesianer_Archive.dbo.WhoIsActive
JOIN (
	SELECT DISTINCT WhoIsActive.collection_time, WhoIsActive.session_id
	FROM Salesianer_Archive.dbo.WhoIsActive
	JOIN (
		SELECT collection_time, blocking_session_id
		FROM Salesianer_Archive.dbo.WhoIsActive
		WHERE blocking_session_id IS NOT NULL
	) blocked_session ON blocked_session.collection_time = WhoIsActive.collection_time AND (blocked_session.blocking_session_id = WhoIsActive.session_id OR WhoIsActive.blocking_session_id IS NOT NULL)
) x ON x.collection_time = WhoIsActive.collection_time AND x.session_id = WhoIsActive.session_id
WHERE WhoIsActive.collection_time > DATEADD(hour, -1, GETDATE())
ORDER BY x.collection_time DESC;