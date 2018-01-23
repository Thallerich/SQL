SELECT Article.ArticleNumber, Localization.Translation AS Artikelbezeichnung, ConsignmentTaskPosition.PackingPosition, ConsignmentTaskPosition.QuantityScanned, ConsignmentTaskPosition.QuantityCommissioned
FROM LaundryAutomation.dbo.ConsignmentTaskPosition, LaundryAutomation.dbo.ConsignmentTask, LaundryAutomation.dbo.Article, LaundryAutomation.dbo.ArticleDescriptionLocalization, LaundryAutomation.dbo.Localization
WHERE ConsignmentTaskPosition.ConsignmentID = ConsignmentTask.ConsignmentID
  AND ConsignmentTaskPosition.ArticleID = Article.ArticleID
  AND ArticleDescriptionLocalization.Article_ArticleID = Article.ArticleID
  AND ArticleDescriptionLocalization.Descriptions_LocalizationID = Localization.LocalizationID
  AND Localization.Code = 'de-DE'
  AND ConsignmentTask.PackingNumber = '11063487'
  AND (ConsignmentTaskPosition.QuantityScanned > 0 OR ConsignmentTaskPosition.QuantityCommissioned > 0)
ORDER BY Article.ArticleNumber;