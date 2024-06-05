SELECT Chip.Sgtin96HexCode, Article.ArticleNumber, Localization.Translation AS ArticleDescription, ClaimedChip.RecordedDate, Reader.[Description], [Location].[Description] AS [Location], ReasonLocalization.Translation AS Reason, LastCustomer = (
    SELECT TOP 1 Customer.[Description] + N' (' + CAST(Customer.Number AS nvarchar) + N')'
    FROM LaundryAutomation.dbo.ConsignmentTask
    JOIN LaundryAutomation.dbo.CodedArticleDelivery ON CodedArticleDelivery.ArticleDeliveryPositions_ConsignmentID = ConsignmentTask.ConsignmentID 
    JOIN LaundryAutomation.dbo.Chip AS DeliveryChip ON CodedArticleDelivery.CodedArticles_ChipID = DeliveryChip.ChipID
    JOIN LaundryAutomation.dbo.Department ON ConsignmentTask.DepartmentID = Department.DepartmentID
    JOIN LaundryAutomation.dbo.Customer ON Department.CustomerID = Customer.CustomerID
    WHERE DeliveryChip.ChipID = Chip.ChipID
      AND ConsignmentTask.ConsignmentTime < ClaimedChip.RecordedDate
    ORDER BY ConsignmentTask.ConsignmentTime DESC
  ),
  LastDepartment = (
    SELECT TOP 1 Department.[Description] + N' (' + Department.Headword + N')'
    FROM LaundryAutomation.dbo.ConsignmentTask
    JOIN LaundryAutomation.dbo.CodedArticleDelivery ON CodedArticleDelivery.ArticleDeliveryPositions_ConsignmentID = ConsignmentTask.ConsignmentID 
    JOIN LaundryAutomation.dbo.Chip AS DeliveryChip ON CodedArticleDelivery.CodedArticles_ChipID = DeliveryChip.ChipID
    JOIN LaundryAutomation.dbo.Department ON ConsignmentTask.DepartmentID = Department.DepartmentID
    WHERE DeliveryChip.ChipID = Chip.ChipID
      AND ConsignmentTask.ConsignmentTime < ClaimedChip.RecordedDate
    ORDER BY ConsignmentTask.ConsignmentTime DESC
  )
FROM LaundryAutomation.dbo.ClaimedChip
JOIN LaundryAutomation.dbo.ClaimedArticle ON ClaimedChip.ClaimedChipID = ClaimedArticle.ClaimedChipID
JOIN LaundryAutomation.dbo.Chip ON ClaimedArticle.ChipID = Chip.ChipID
LEFT JOIN LaundryAutomation.dbo.Article ON Chip.ArticleID = Article.ArticleID
LEFT JOIN LaundryAutomation.dbo.ArticleDescriptionLocalization ON ArticleDescriptionLocalization.Article_ArticleID = Article.ArticleID
LEFT JOIN LaundryAutomation.dbo.Localization ON ArticleDescriptionLocalization.Descriptions_LocalizationID = Localization.LocalizationID
JOIN LaundryAutomation.dbo.Reader ON ClaimedChip.ReaderID = Reader.ReaderID
JOIN LaundryAutomation.dbo.[Location] ON Reader.LocationID = [Location].LocationID
JOIN LaundryAutomation.dbo.ClaimReason ON ClaimedChip.ClaimReasonID = ClaimReason.ClaimReasonID
JOIN LaundryAutomation.dbo.ClaimReasonLocalizations ON ClaimReason.ClaimReasonID = ClaimReasonLocalizations.ClaimReason_ClaimReasonID
JOIN LaundryAutomation.dbo.Localization AS ReasonLocalization ON ClaimReasonLocalizations.Localization_LocalizationID = ReasonLocalization.LocalizationID
WHERE Localization.Code = 'de-DE'
  AND ReasonLocalization.Code = 'de-DE'
  AND ClaimedChip.RecordedDate BETWEEN N'2024-05-01 00:00:00.000' AND GETDATE()
ORDER BY RecordedDate DESC;