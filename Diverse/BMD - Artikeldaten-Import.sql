DECLARE @ImportFile nvarchar(200) = N'\\atenadvantex01\AdvanTex\Temp\Preise und Lieferanten.xlsx';
DECLARE @ImportSQLTextil nvarchar(max);
DECLARE @ImportSQLHW nvarchar(max);

DECLARE @ImportTextil TABLE (
  BMDArtNr nchar(10) COLLATE Latin1_General_CS_AS,
  ADVArtNr nchar(15) COLLATE Latin1_General_CS_AS,
  ADVLiefNr int,
  ADVLiefID int,
  ArtikelBez nvarchar(60) COLLATE Latin1_General_CS_AS,
  EKPreis money
);

DECLARE @ImportHW TABLE (
  Lieferant nvarchar(60) COLLATE Latin1_General_CS_AS,
  BMDArtNr nchar(10) COLLATE Latin1_General_CS_AS,
  ADVArtNr nchar(15) COLLATE Latin1_General_CS_AS,
  ADVLiefNr int,
  ADVLiefID int,
  ArtikelBez nvarchar(60) COLLATE Latin1_General_CS_AS,
  EKPreis money,
  VPE int,
  VPEEinheit nchar(10) COLLATE Latin1_General_CS_AS
);

SET @ImportSQLTextil = N'SELECT CAST(BMD_ArtNr AS nchar(10)), ' +
  N'CAST(ADV_ArtNr AS nchar(15)), ' +
  N'CAST(ADV_LiefNr AS int), ' +
  N'CAST(Artikelbezeichnung AS nvarchar(60)), ' +
  N'CAST(EKPreis AS money) ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [Textilien$]);';

SET @ImportSQLHW = N'SELECT CAST(Lieferant AS nvarchar(60)), ' +
  N'CAST(BMD_ArtNr AS nchar(10)), ' +
  N'CAST(ADV_ArtNr AS nchar(15)), ' +
  N'CAST(ADV_LiefNr AS int), ' +
  N'CAST(Artikelbezeichnung AS nvarchar(60)), ' +
  N'CAST(EKPreis AS money), ' +
  N'CAST(VPE AS int), ' +
  N'CAST(VPE_Einheit AS nchar(10)) ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [HW$]);';

INSERT INTO @ImportTextil (BMDArtNr, ADVArtNr, ADVLiefNr, ArtikelBez, EKPreis)
EXEC sp_executesql @ImportSQLTextil;

INSERT INTO @ImportHW (Lieferant, BMDArtNr, ADVArtNr, ADVLiefNr, ArtikelBez, EKPreis, VPE, VPEEinheit)
EXEC sp_executesql @ImportSQLHW;

UPDATE ITX SET ADVLiefID = Lief.ID
FROM @ImportTextil AS ITX
JOIN Lief ON ITX.ADVLiefNr = Lief.LiefNr;

UPDATE IHW SET ADVLiefID = Lief.ID
FROM @ImportHW AS IHW
JOIN Lief ON IHW.ADVLiefNr = Lief.LiefNr;

--SELECT Artikel.ArtikelNr, Artikel.ArtikelBez, ImportTextil.ArtikelBez, Artikel.EkPreis, ImportTextil.EKPreis, Lief.LiefNr, Lief.SuchCode AS Lieferant, ImportTextil.ADVLiefNr, ImportTextil.ADVLiefID
UPDATE Artikel SET Artikel.EkPreis = ImportTextil.EKPreis, Artikel.LiefID = ISNULL(ImportTextil.ADVLiefID, Artikel.LiefID)
FROM @ImportTextil AS ImportTextil
JOIN Artikel ON ImportTextil.ADVArtNr = Artikel.ArtikelNr
JOIN Lief ON Artikel.LiefID = Lief.ID
WHERE (Artikel.EkPreis != ImportTextil.EKPreis OR (Lief.LiefNr != ImportTextil.ADVLiefNr AND ImportTextil.ADVLiefNr IS NOT NULL));

--SELECT Artikel.ArtikelNr, Artikel.ArtikelBez, ImportHW.ArtikelBez, Artikel.EkPreis, ImportHW.EKPreis, Artikel.PackMenge, ME.MeBez AS ME, ImportHW.VPE, ImportHW.VPEEinheit, Lief.LiefNr, Lief.SuchCode AS Lieferant, ImportHW.ADVLiefNr, ImportHW.ADVLiefID
UPDATE Artikel SET Artikel.EkPreis = ImportHW.EKPreis, Artikel.LiefID = ISNULL(ImportHW.ADVLiefID, Artikel.LiefID)
FROM @ImportHW AS ImportHW
JOIN Artikel ON ImportHW.ADVArtNr = Artikel.ArtikelNr
JOIN Lief ON Artikel.LiefID = Lief.ID
JOIN ME ON Artikel.MEID = ME.ID
WHERE (Artikel.EkPreis != (ImportHW.EKPreis / ImportHW.VPE) OR (Lief.LiefNr != ImportHW.ADVLiefNr AND ImportHW.ADVLiefNr IS NOT NULL));