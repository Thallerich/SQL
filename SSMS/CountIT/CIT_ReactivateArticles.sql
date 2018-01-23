SELECT LaundryAutomation.dbo.Article.*
FROM LaundryAutomation.dbo.Article
WHERE CONVERT(date, LaundryAutomation.dbo.Article.LastTransmissionDate) >= CONVERT(date, DATEADD(day, -1, GETDATE()))
  AND CONVERT(date, LaundryAutomation.dbo.Article.LastTransmissionDate) < CONVERT(date, GETDATE());

/* Reactivate Articles ################ */
UPDATE LaundryAutomation.dbo.Article SET LastTransmissionDate = GETDATE()
WHERE CONVERT(date, LaundryAutomation.dbo.Article.LastTransmissionDate) >= CONVERT(date, DATEADD(day, -1, GETDATE()))
  AND CONVERT(date, LaundryAutomation.dbo.Article.LastTransmissionDate) < CONVERT(date, GETDATE());