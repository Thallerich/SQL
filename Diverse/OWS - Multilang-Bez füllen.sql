USE OWS
GO

DECLARE @TableName nvarchar(8);
DECLARE @FieldName nvarchar(24);
DECLARE @SQL nvarchar(max);

DECLARE MulitlangFields CURSOR LOCAL STATIC FORWARD_ONLY READ_ONLY FOR
SELECT TabName.TabName AS TableName, TabField.Name AS TableField
FROM dbsystem.dbo.TabField
JOIN dbsystem.dbo.TabName ON TabField.TabNameID = TabName.ID
WHERE IsMultiLangField = 1;

OPEN MulitlangFields;

FETCH NEXT FROM MulitlangFields
INTO @TableName, @FieldName;

WHILE @@FETCH_STATUS = 0
BEGIN
  SET @SQL = N'UPDATE ' + @TableName + N' SET ' + @FieldName + N'1 = ' + @FieldName + N' WHERE ' + @FieldName + N'1 IS NULL AND ' + @FieldName + N' IS NOT NULL;';
  EXEC (@SQL);

  SET @SQL = N'UPDATE ' + @TableName + N' SET ' + @FieldName + N'2 = ' + @FieldName + N' WHERE ' + @FieldName + N'2 IS NULL AND ' + @FieldName + N' IS NOT NULL;';
  EXEC (@SQL);

  FETCH NEXT FROM MulitlangFields
  INTO @TableName, @FieldName;
END

GO