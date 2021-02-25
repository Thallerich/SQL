IF OBJECT_ID(N'tempdb..#AdvUHF') IS NOT NULL
  DROP TABLE #AdvUHF;

GO

DECLARE @Anlage datetime = DATEADD(day, -7, GETDATE());

CREATE TABLE #AdvUHF (
  Code nchar(24),
  ArtikelNr nchar(15),
  Groesse nchar(12)
);

INSERT INTO #AdvUHF (Code, ArtikelNr, Groesse)
SELECT OPTeile.Code, Artikel.ArtikelNr, ArtGroe.Groesse
FROM [SALADVPSQLC1A1.SALRES.COM].Salesianer.dbo.OPTeile
JOIN [SALADVPSQLC1A1.SALRES.COM].Salesianer.dbo.ArtGroe ON OPTeile.ArtGroeID = ArtGroe.ID
JOIN [SALADVPSQLC1A1.SALRES.COM].Salesianer.dbo.Artikel ON ArtGroe.ArtikelID = Artikel.ID
WHERE LEN(OPTeile.Code) = 24
  AND OPTeile.Anlage_ > @Anlage;

UPDATE #AdvUHF SET ArtikelNr = ProductSizeConversion.singlesizeproduct
FROM LaundryAutomation.dbo.ProductSizeConversion
INNER JOIN #AdvUHF ON (ProductSizeConversion.multisizeproduct = #AdvUHF.Code AND ProductSizeConversion.sizecode = #AdvUHF.Groesse);

GO

INSERT INTO LaundryAutomation.dbo.SalesianerChip (ArticleID, Sgtin96HexCode, IsEncoded, Created, LastUpdated)
SELECT Article.ArticleID, AdvUHF.Code, 0 AS IsEncoded, GETDATE() AS Created, GETDATE() AS LastUpdated
FROM #AdvUHF AS AdvUHF
JOIN (
  SELECT a.ArticleID, a.ArticleNumber
  FROM LaundryAutomation.dbo.Article AS a
  WHERE a.LastTransmissionDate >= DATEADD(day, -7, GETDATE())
) AS Article ON Article.ArticleNumber = AdvUHF.ArtikelNr
WHERE NOT EXISTS (
    SELECT SalesianerChip.*
    FROM LaundryAutomation.dbo.SalesianerChip
    WHERE SalesianerChip.Sgtin96HexCode = AdvUHF.Code
  )
  AND NOT EXISTS (
    SELECT Chip.*
    FROM LaundryAutomation.dbo.Chip
    WHERE Chip.Sgtin96HexCode = AdvUHF.Code
  )
  AND NOT EXISTS (
    SELECT Chip.*
    FROM AdvanTexSync.dbo.Chip
    WHERE Chip.Sgtin96HexCode = AdvUHF.Code
  );

GO