DECLARE @db_id int = DB_ID();
DECLARE @object_id int = OBJECT_ID('dbo.REPQUEUE');
DECLARE @vgr_count bigint;

SELECT @vgr_count = sum(version_ghost_record_count)
FROM sys.dm_db_index_physical_stats (@db_id, @object_id, 0, NULL, 'detailed');

IF @vgr_count > 1000000
  SELECT CAST(N'Version ghost record count in REPQUEUE is at ' + FORMAT(@vgr_count, N'##,#', N'de-AT') + N'!' AS nvarchar(60)) AS [Alert];