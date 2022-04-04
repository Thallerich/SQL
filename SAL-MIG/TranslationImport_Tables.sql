DECLARE @sqltext nvarchar(max);
DECLARE @TableName nvarchar(40);
DECLARE @Table nvarchar(20);

DECLARE TranslationTable CURSOR LOCAL FAST_FORWARD FOR
  SELECT TABLE_NAME
  FROM INFORMATION_SCHEMA.TABLES
  WHERE TABLE_NAME LIKE N'@_Translation%' ESCAPE N'@';

OPEN TranslationTable;
FETCH NEXT FROM TranslationTable INTO @TableName;

WHILE @@FETCH_STATUS = 0
BEGIN
  SET @Table = REPLACE(@TableName, N'_Translation', N'');

  SET @sqltext = N'
    UPDATE Salesianer_Test.dbo.' + @Table + N' SET ' + @Table + N'Bez7 = HR, ' + @Table + N'Bez8 = SI
    FROM Salesianer.dbo.' + @TableName + N'
    WHERE ' + @TableName + N'.ID = ' + @Table + N'.ID;';

  PRINT @sqltext;

  FETCH NEXT FROM TranslationTable INTO @TableName;
END;

CLOSE TranslationTable;
DEALLOCATE TranslationTable;