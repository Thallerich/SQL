MERGE INTO Wozabal.dbo.LangTran AS target
USING (
  SELECT LangTran.LanguageID, LangTran.SourceText, LangTran.TranslatedText, LangTran.LastModified, LangTran.TranslateUser
  FROM Wozabal_Test.dbo.LangTran
  WHERE LangTran.LastModified = CAST(GETDATE() AS date)
) AS source (LanguageID, SourceText, TranslatedText, LastModified, TranslateUser)
ON target.LanguageID = source.LanguageID AND target.SourceText = source.SourceText
WHEN MATCHED
  THEN UPDATE SET target.TranslatedText = source.TranslatedText, target.LastModified = source.LastModified, target.TranslateUser = source.TranslateUser
WHEN NOT MATCHED BY target
  THEN INSERT (LanguageID, SourceText, TranslatedText, LastModified, TranslateUser) VALUES (source.LanguageID, source.SourceText, source.TranslatedText, source.LastModified, source.TranslateUser);