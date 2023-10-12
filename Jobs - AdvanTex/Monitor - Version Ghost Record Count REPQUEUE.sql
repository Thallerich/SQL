DECLARE @db_id int = DB_ID();
DECLARE @object_id int = OBJECT_ID('dbo.REPQUEUE');
DECLARE @index_id int = (SELECT index_id FROM sys.indexes WHERE object_id = @object_id AND [name] = 'Seq');
DECLARE @vgr_count bigint;

SELECT @vgr_count = sum(version_ghost_record_count)
FROM sys.dm_db_index_physical_stats (@db_id, @object_id, @index_id, NULL, 'detailed');

IF @vgr_count > 200000
  SELECT N'Version ghost record count in REPQUEUE is at ' + FORMAT(@vgr_count, N'##,#', N'de-AT') + N'!' AS [Alert];