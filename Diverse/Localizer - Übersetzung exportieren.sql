SELECT LangTran.SourceText AS [german], COALESCE(LangTran.TranslatedText, sysLangTran.TranslatedText) AS [czech]
FROM LangTran
JOIN [Language] ON LangTran.LanguageID = [Language].ID
JOIN dbsystem.dbo.LangTran AS sysLangTran ON LangTran.SourceText = sysLangTran.SourceText
WHERE LangTran.LanguageID = 7;