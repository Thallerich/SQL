WITH CurrentArticle AS (
  SELECT a.ArticleID, a.ArticleNumber
  FROM LaundryAutomation.dbo.Article AS a
  WHERE a.LastTransmissionDate >= DATEADD(day, -7, GETDATE())
)
UPDATE SalesianerChip SET ArticleID = CurrentArticle.ArticleID
--SELECT SalesianerChip.*, CurrentArticle.ArticleID
FROM SalesianerChip
JOIN __AdvUHF ON __AdvUHF.Code = SalesianerChip.Sgtin96HexCode
JOIN CurrentArticle ON __AdvUHF.ArtikelNr = CurrentArticle.ArticleNumber
WHERE SalesianerChip.ArticleID != CurrentArticle.ArticleID;