DROP TABLE IF EXISTS #LangTranFix;

GO

CREATE TABLE #LangTranFix (
  LangTranID int,
  TranslatedText nvarchar(120) COLLATE Latin1_General_CS_AS
);

GO

INSERT INTO #LangTranFix (LangTranID, TranslatedText)
--SELECT LangTran.ID AS LangTranID, LangTran.SourceText, LangTran.TranslatedText, MigLangTran.TranslatedText AS Mig_TranslatedText, LangTran.TranslateUser, LangTran.LastModified
SELECT LangTran.ID, MigLangTran.TranslatedText
FROM LangTran
JOIN (
  SELECT LangTran.*
  FROM [SALSVATTSAMIG1.sal.co.at].Salesianer_Test.dbo.LangTran
) AS MigLangTran ON LangTran.LanguageID = MigLangTran.LanguageID AND LangTran.SourceText = MigLangTran.SourceText
WHERE LEFT(LangTran.TranslatedText, 1) = N'#'
  AND LEFT(MigLangTran.TranslatedText, 1) != N'#';

GO

UPDATE Salesianer.dbo.LangTran SET TranslatedText = #LangTranFix.TranslatedText, TranslateUser = N'THALST', LastModified = CAST(GETDATE() AS date), UserID_ = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST')
FROM #LangTranFix
WHERE #LangTranFix.LangTranID = LangTran.ID;

GO