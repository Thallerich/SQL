USE LaundryAutomation

-- codierte Teile
SELECT ct.PackingNumber, ct.ConsignmentTime, c.Sgtin96HexCode, a.ArticleNumber, a.EanNumber
FROM ConsignmentTask ct
INNER JOIN CodedArticleDelivery cad ON cad.ArticleDeliveryPositions_ConsignmentID = ct.ConsignmentID 
INNER JOIN Chip c ON cad.CodedArticles_ChipID = c.ChipID
INNER JOIN Article a ON c.ArticleID = a.ArticleID
WHERE ct.PackingNumber IN ('11557916')
ORDER BY ct.PackingNumber, a.ArticleNumber

GO