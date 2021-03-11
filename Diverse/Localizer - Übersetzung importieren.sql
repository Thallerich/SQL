DROP TABLE IF EXISTS _LanguageImportTable;
DROP TABLE IF EXISTS __Translations;
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

DECLARE @Language nchar(5) = N'ro_RO';
DECLARE @LanguageID int;

/* DECLARE @ImportTable TABLE (
  SourceText nvarchar(200) COLLATE Latin1_General_CS_AS,
  TranslatedText nvarchar(200) COLLATE Latin1_General_CS_AS
); */

SET @LanguageID = (SELECT ID FROM [Language] WHERE [Language].ISO = @Language);

INSERT INTO _LanguageImportTable (ID, LanguageID, SourceText, TranslatedText)
SELECT ROW_NUMBER() OVER (ORDER BY SourceText) AS ID, @LanguageID, SourceText, LEFT(TranslatedText, 120) AS TranslatedText
FROM __Translations;

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