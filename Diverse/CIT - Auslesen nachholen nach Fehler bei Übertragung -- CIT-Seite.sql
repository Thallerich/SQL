USE LaundryAutomation
GO

-- codierte Teile
INSERT INTO [SALADVPSQLC1A1.SALRES.COM].Salesianer.dbo.__CITScan (PackingNumber, ConsignmentTime, HexCode, ArticleNumber, EAN, VsaID, DeliveryDate)
SELECT ct.PackingNumber, ct.ConsignmentTime, c.Sgtin96HexCode, a.ArticleNumber, a.EanNumber, ct.DepartmentID, CAST(ct.DeliveryDate AS date)
FROM ConsignmentTask ct
INNER JOIN CodedArticleDelivery cad ON cad.ArticleDeliveryPositions_ConsignmentID = ct.ConsignmentID 
INNER JOIN Chip c ON cad.CodedArticles_ChipID = c.ChipID
INNER JOIN Article a ON c.ArticleID = a.ArticleID
WHERE ct.DepartmentID IN (2649)
  AND EXISTS (
    SELECT ConsignmentTask.*
    FROM AdvanTexSync.dbo.ConsignmentTask
    WHERE ConsignmentTask.PackingNumber = ct.PackingNumber
      AND ConsignmentTask.SyncState >= 11
      AND ConsignmentTask.DeliveryDate > N'2022-08-24'
  )
ORDER BY ct.PackingNumber, a.ArticleNumber

GO