DECLARE @Filename nvarchar(100);
DECLARE @BulkSQL nvarchar(max);

SET @Filename = N'all-2301_2018-04-11-999999.txt';

CREATE TABLE #Inventur (
  Chipcode nvarchar(100) COLLATE Latin1_General_CS_AS
);

SET @BulkSQL = N'BULK INSERT #Inventur FROM N''D:\AdvanTex\Temp\uhf\' + @Filename + '''WITH (FIELDTERMINATOR = N''\r'', ROWTERMINATOR = N''\n'');';
EXEC(@BulkSQL);

SELECT DISTINCT Chipcode FROM #Inventur;

DROP TABLE IF EXISTS #Inventur;