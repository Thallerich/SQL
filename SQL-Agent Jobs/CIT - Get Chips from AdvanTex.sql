IF OBJECT_ID(N'tempdb..#AdvUHF') IS NOT NULL
  DROP TABLE #AdvUHF;

IF OBJECT_ID(N'tempdb..#AdvUHF2') IS NOT NULL
  DROP TABLE #AdvUHF2;

GO

CREATE TABLE #AdvUHF (
  Code nchar(24),
  ArtikelNr nchar(15),
  Groesse nchar(12)
);

CREATE TABLE #AdvUHF2 (
  Code nchar(33),
  Code2 nchar(33),
  ArtikelNr nchar(15),
  Groesse nchar(12)
);

INSERT INTO #AdvUHF2 (Code, Code2, ArtikelNr, Groesse)
SELECT EinzTeil.Code COLLATE Latin1_General_CI_AS AS Code, EinzTeil.Code2 COLLATE Latin1_General_CI_AS AS Code2, Artikel.ArtikelNr COLLATE Latin1_General_CI_AS AS ArtikelNr, ArtGroe.Groesse COLLATE Latin1_General_CI_AS AS Groesse
FROM [SALADVPSQLC1A1.salres.com].Salesianer.dbo.EinzTeil
JOIN [SALADVPSQLC1A1.salres.com].Salesianer.dbo.ArtGroe ON EinzTeil.ArtGroeID = ArtGroe.ID
JOIN [SALADVPSQLC1A1.salres.com].Salesianer.dbo.Artikel ON ArtGroe.ArtikelID = Artikel.ID
WHERE EinzTeil.Update_ > DATEADD(hour, -1, GETDATE())
  AND EinzTeil.ArtikelID > 0;

INSERT INTO #AdvUHF (Code, ArtikelNr, Groesse)
SELECT IIF(LEN(AdvTeile.Code) = 24, AdvTeile.Code, AdvTeile.Code2) AS Code, AdvTeile.ArtikelNr, AdvTeile.Groesse
FROM #AdvUHF2 AdvTeile
WHERE (LEN(AdvTeile.Code) = 24 OR LEN(AdvTeile.Code2) = 24)
  AND NOT EXISTS (
    SELECT SalesianerChip.Sgtin96HexCode
    FROM LaundryAutomation.dbo.SalesianerChip
    JOIN LaundryAutomation.dbo.Article ON SalesianerChip.ArticleID = Article.ArticleID
    WHERE SalesianerChip.Sgtin96HexCode = AdvTeile.Code
      AND Article.ArticleNumber = AdvTeile.ArtikelNr
  )
  AND NOT EXISTS (
    SELECT Chip.Sgtin96HexCode
    FROM LaundryAutomation.dbo.Chip
	  JOIN LaundryAutomation.dbo.Article ON Chip.ArticleID = Article.ArticleID
    WHERE Chip.Sgtin96HexCode = AdvTeile.Code
	    AND Article.ArticleNumber = AdvTeile.ArtikelNr
  );

UPDATE #AdvUHF SET ArtikelNr = ProductSizeConversion.singlesizeproduct
FROM LaundryAutomation.dbo.ProductSizeConversion
INNER JOIN #AdvUHF ON (ProductSizeConversion.multisizeproduct = #AdvUHF.ArtikelNr AND ProductSizeConversion.sizecode = #AdvUHF.Groesse);

GO

MERGE INTO LaundryAutomation.dbo.SalesianerChip
USING (
  SELECT DISTINCT Article.ArticleID, AdvUHF.Code
  FROM #AdvUHF AS AdvUHF
  JOIN (
    SELECT a.ArticleID, a.ArticleNumber
    FROM LaundryAutomation.dbo.Article AS a
    WHERE a.LastTransmissionDate >= DATEADD(day, -7, GETDATE())
  ) AS Article ON Article.ArticleNumber = AdvUHF.ArtikelNr
) AS AdvChanged ON AdvChanged.Code = SalesianerChip.Sgtin96HexCode
WHEN MATCHED THEN
  UPDATE SET ArticleID = AdvChanged.ArticleID, LastUpdated = GETDATE()
WHEN NOT MATCHED THEN
  INSERT (ArticleID, Sgtin96HexCode, IsEncoded, Created, LastUpdated)
  VALUES (AdvChanged.ArticleID, AdvChanged.Code, 0, GETDATE(), GETDATE());

GO