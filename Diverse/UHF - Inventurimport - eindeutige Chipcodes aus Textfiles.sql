DECLARE @Path nvarchar(100) = N'D:\AdvanTex\Temp\uhf\';
DECLARE @Filename nvarchar(100);
DECLARE @Command nvarchar(150);
DECLARE @BulkSQL nvarchar(max);

DECLARE @Files TABLE (
  [Filename] nvarchar(100)
);

DROP TABLE IF EXISTS #Inventur;

CREATE TABLE #Inventur (
  Chipcode nvarchar(100) COLLATE Latin1_General_CS_AS
);

SET @Command = 'dir ' + @Path + '*.txt /b';

INSERT INTO @Files
EXEC master..xp_cmdShell @Command;

DELETE FROM @Files WHERE [Filename] IS NULL;

DECLARE Files CURSOR FOR
  SELECT [Filename]
  FROM @Files;

OPEN Files;

FETCH NEXT FROM Files INTO @Filename;

WHILE @@FETCH_STATUS = 0
BEGIN
  SET @BulkSQL = N'BULK INSERT #Inventur FROM ''' + @Path + @Filename + '''WITH (FIELDTERMINATOR = N''\r'', ROWTERMINATOR = N''\n'');';
  EXEC(@BulkSQL);

  FETCH NEXT FROM Files INTO @Filename;
END;

CLOSE Files;
DEALLOCATE Files;

SELECT DISTINCT Chipcode FROM #Inventur;

DROP TABLE IF EXISTS #Inventur;