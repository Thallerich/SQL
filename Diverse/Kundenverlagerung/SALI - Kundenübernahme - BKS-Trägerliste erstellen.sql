DECLARE @ImportFile nvarchar(200) = N'\\atenadvantex01\AdvanTex\Temp\LKWaidhofenYbbsDCSTraeger.xls';
DECLARE @ImportFileGrMap nvarchar(200) = N'\\atenadvantex01\AdvanTex\Temp\LKWaidhofenYbbsDCSGrMap.xlsx';
DECLARE @XLSXImportSQL nvarchar(max);

DECLARE @ImportTablePersonal TABLE (
  PersID nvarchar(10) COLLATE Latin1_General_CS_AS,
  MediumID nchar(6) COLLATE Latin1_General_CS_AS,
  Nachname nvarchar(50) COLLATE Latin1_General_CS_AS,
  Vorname nvarchar(50) COLLATE Latin1_General_CS_AS,
  Anrede nvarchar(50) COLLATE Latin1_General_CS_AS,
  Traeger int
);

DECLARE @ImportTableArtikelprofil TABLE (
  PersID nvarchar(10) COLLATE Latin1_General_CS_AS,
  ArtNr nchar(3) COLLATE Latin1_General_CS_AS,
  ArtGr nchar(10) COLLATE Latin1_General_CS_AS
);

DECLARE @ImportTableGrMap TABLE (
  ArtNrSAL nchar(15) COLLATE Latin1_General_CS_AS,
  ArtikelSAL nvarchar(60) COLLATE Latin1_General_CS_AS,
  ArtGrSAL nchar(10) COLLATE Latin1_General_CS_AS,
  ArtikelWoz nvarchar(60) COLLATE Latin1_General_CS_AS,
  ArtGrWoz nchar(10) COLLATE Latin1_General_CS_AS
);

SET @XLSXImportSQL = N'SELECT CAST(PersID AS nvarchar(10)), ' +
  N'CAST(MediumID AS nchar(6)), ' +
  N'CAST(Nachname AS nvarchar(50)), ' +
  N'CAST(Vorname AS nvarchar(50)), ' +
  N'CAST(Anrede AS nvarchar(50)), ' +
  N'ROW_NUMBER() OVER (ORDER BY Nachname) + 1 AS Traeger ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [Personal$]);';

INSERT INTO @ImportTablePersonal
EXEC sp_executesql @XLSXImportSQL;

SET @XLSXImportSQL = N'SELECT CAST(PersID AS nvarchar(10)), ' +
  N'CAST(ArtNr AS nchar(3)), ' +
  N'CAST(ArtGr AS nchar(3)) ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [Artikelprofil$]);';

INSERT INTO @ImportTableArtikelprofil
EXEC sp_executesql @XLSXImportSQL;

SET @XLSXImportSQL = N'SELECT CAST(ArtNrSAL AS nchar(15)) AS ArtNrSAL, ' +
  N'CAST(ArtikelSAL AS nvarchar(60)) AS ArtikelSAL, ' +
  N'CAST(ArtGrSAL AS nchar(10)) AS ArtGrSAL, ' +
  N'CAST(ArtikelWoz AS nvarchar(60)) AS ArtikelWoz, ' +
  N'CAST(ArtGrWoz AS nchar(10)) AS ArtGrWoz ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFileGrMap+''', [GrMap$]);';

INSERT INTO @ImportTableGrMap
EXEC sp_executesql @XLSXImportSQL;

SELECT Personal.Traeger AS TraegerNr, Personal.Vorname, Personal.Nachname, Personal.MediumID AS PersNr, Personal.PersID AS RentomatKarte, Personal.Anrede AS Titel, Artikelprofil.ArtNr, Artikel.ArtikelBez, GrMap.ArtGrWoz AS ArtGr
FROM @ImportTableArtikelprofil AS Artikelprofil
JOIN @ImportTablePersonal AS Personal ON Artikelprofil.PersID = Personal.PersID
JOIN @ImportTableGrMap AS GrMap ON Artikelprofil.ArtNr = GrMap.ArtNrSAL AND Artikelprofil.ArtGr = GrMap.ArtGrSAL
JOIN Artikel ON Artikelprofil.ArtNr = Artikel.ArtikelNr;