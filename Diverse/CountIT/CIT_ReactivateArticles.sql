DECLARE @LastSuccessDate date;

SELECT @LastSuccessDate = Datum
FROM (
  SELECT TOP 1 CAST(LastTransmissionDate AS date) Datum, COUNT(ArticleID) Anzahl
  FROM LaundryAutomation.dbo.Article
  GROUP BY CAST(LastTransmissionDate AS date)
  ORDER BY Anzahl DESC
) x;

SELECT LaundryAutomation.dbo.Article.*
FROM LaundryAutomation.dbo.Article
WHERE CONVERT(date, LaundryAutomation.dbo.Article.LastTransmissionDate) >= @LastSuccessDate
  AND CONVERT(date, LaundryAutomation.dbo.Article.LastTransmissionDate) < CONVERT(date, GETDATE());

/* Reactivate Articles ################ */
UPDATE LaundryAutomation.dbo.Article SET LastTransmissionDate = GETDATE()
WHERE CONVERT(date, LaundryAutomation.dbo.Article.LastTransmissionDate) >= @LastSuccessDate
  AND CONVERT(date, LaundryAutomation.dbo.Article.LastTransmissionDate) < CONVERT(date, GETDATE());