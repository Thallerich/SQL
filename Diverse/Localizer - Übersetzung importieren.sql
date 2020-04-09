DROP TABLE IF EXISTS _SKLanguageImportTable;
GO

CREATE TABLE _SKLanguageImportTable (
  ID int,
  LanguageID int DEFAULT 6,
  SourceText nvarchar(120) COLLATE Latin1_General_CS_AS,
  TranslatedText nvarchar(120) COLLATE Latin1_General_CS_AS,
  LastModified date DEFAULT CAST(GETDATE() AS date),
  TranslateUser varchar(8) COLLATE Latin1_General_CS_AS DEFAULT N'THALST'
);

GO

DECLARE @ImportFile nvarchar(200) = N'\\atenadvantex01.wozabal.int\AdvanTex\Temp\SK_Translation.xlsx';
DECLARE @XLSXImportSQL nvarchar(max);

DECLARE @ImportTable TABLE (
  SourceText nvarchar(200) COLLATE Latin1_General_CS_AS,
  TranslatedText nvarchar(200) COLLATE Latin1_General_CS_AS
);

SET @XLSXImportSQL = N'SELECT * ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [SKTranslation$]);';

INSERT INTO @ImportTable
EXEC sp_executesql @XLSXImportSQL;

INSERT INTO _SKLanguageImportTable (ID, SourceText, TranslatedText)
SELECT ROW_NUMBER() OVER (ORDER BY SourceText) AS ID, SourceText, LEFT(TranslatedText, 120) AS TranslatedText
FROM @ImportTable;

GO

DELETE FROM _SKLanguageImportTable
WHERE ID IN (
  SELECT MaxID
  FROM (
    SELECT MAX(ID) AS MaxID, SourceText
    FROM _SKLanguageImportTable
    GROUP BY SourceText
    HAVING COUNT(ID) > 1
  ) AS x
);

GO