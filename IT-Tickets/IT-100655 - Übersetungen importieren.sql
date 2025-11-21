SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

DECLARE @sqltext nvarchar(max), @msg nvarchar(max);
DECLARE @TableName varchar(8), @FieldName varchar(11);
DECLARE @maxlength int;
DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = UPPER(REPLACE(ORIGINAL_LOGIN(), N'SAL\', N'')));
DECLARE @languageid tinyint = 3; /* 3 = Romanian */

DECLARE curTables CURSOR FOR
SELECT DISTINCT TableName, TableName + N'BEZ' AS FieldName
FROM _IT100655;

OPEN curTables;
FETCH NEXT FROM curTables INTO @TableName, @FieldName;

WHILE @@FETCH_STATUS = 0
BEGIN

	SELECT @maxlength = viewTabField.[Len]
	FROM viewTabField
	WHERE viewTabField.TabNameID = (SELECT ID FROM viewTabName WHERE TabName = @TableName)
		AND UPPER(viewTabField.[Name]) = @FieldName;

	SET @sqltext = N'UPDATE ' + @TableName + N' SET ' + @TableName + N'Bez' + CAST(@languageid AS nvarchar(1)) + N' = LEFT(_IT100655.[Bezeichnung RO], ' + CAST(@maxlength AS nvarchar) + N'), UserID_ = ' + CAST(@userid AS nvarchar) + '
		FROM _IT100655
		WHERE _IT100655.TableID = ' + @TableName + N'.ID
		  AND _IT100655.TableName = ''' + @TableName + N''';';

	EXEC sp_executesql @sqltext;

	SELECT @msg = N'Table: ' + @TableName + N': Updated ' + FORMAT(@@ROWCOUNT, N'#') + N' rows.';
	RAISERROR(@msg, 0, 1) WITH NOWAIT;

	FETCH NEXT FROM curTables INTO @TableName, @FieldName;
END;

CLOSE curTables;
DEALLOCATE curTables;

GO