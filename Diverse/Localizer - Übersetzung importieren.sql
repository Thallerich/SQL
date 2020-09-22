DROP TABLE IF EXISTS _LanguageImportTable;
GO

CREATE TABLE _LanguageImportTable (
  ID int,
  LanguageID int,
  SourceText nvarchar(120) COLLATE Latin1_General_CS_AS,
  TranslatedText nvarchar(120) COLLATE Latin1_General_CS_AS,
  LastModified date DEFAULT CAST(GETDATE() AS date),
  TranslateUser varchar(8) COLLATE Latin1_General_CS_AS DEFAULT N'THALST'
);

GO

DECLARE @Language nchar(5) = N'hu_HU';
DECLARE @LanguageID int;
DECLARE @ImportFile nvarchar(200) = N'\\atenadvantex01.wozabal.int\AdvanTex\Temp\HU_Translation.xlsx';
DECLARE @XLSXImportSQL nvarchar(max);

DECLARE @ImportTable TABLE (
  SourceText nvarchar(200) COLLATE Latin1_General_CS_AS,
  TranslatedText nvarchar(200) COLLATE Latin1_General_CS_AS
);

SET @XLSXImportSQL = N'SELECT * ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [Sheet1$]);';

INSERT INTO @ImportTable
EXEC sp_executesql @XLSXImportSQL;

SET @LanguageID = (SELECT ID FROM [Language] WHERE [Language].ISO = @Language);

INSERT INTO _LanguageImportTable (ID, LanguageID, SourceText, TranslatedText)
SELECT ROW_NUMBER() OVER (ORDER BY SourceText) AS ID, @LanguageID, SourceText, LEFT(TranslatedText, 120) AS TranslatedText
FROM @ImportTable;

DELETE FROM _LanguageImportTable
WHERE ID IN (
  SELECT MaxID
  FROM (
    SELECT MAX(ID) AS MaxID, SourceText
    FROM _LanguageImportTable
    GROUP BY SourceText
    HAVING COUNT(ID) > 1
  ) AS x
);

DELETE FROM _LanguageImportTable
WHERE ID IN (
  SELECT _LanguageImportTable.ID
  FROM _LanguageImportTable
  JOIN LangTran ON LangTran.SourceText = _LanguageImportTable.SourceText
  WHERE LangTran.LanguageID = @LanguageID
    AND LangTran.TranslatedText = _LanguageImportTable.TranslatedText
);

GO