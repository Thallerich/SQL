/*
CREATE TABLE __DCSLKAmstettenProfil (
  PersID nchar(10) COLLATE Latin1_General_CS_AS,
  ArtNr nchar(3) COLLATE Latin1_General_CS_AS,
  ArtGr nchar(10) COLLATE Latin1_General_CS_AS,
  ArtKredit int
);

CREATE TABLE __DCSLKAmstettenPersonal (
  PersID nchar(10) COLLATE Latin1_General_CS_AS,
  MediumID nvarchar(25) COLLATE Latin1_General_CS_AS,
  Nachname nvarchar(25) COLLATE Latin1_General_CS_AS,
  Vorname nvarchar(20) COLLATE Latin1_General_CS_AS,
  Anrede nvarchar(20) COLLATE Latin1_General_CS_AS
);

CREATE TABLE __DCSLKAmstettenGRMap (
  ArtNr nchar(3) COLLATE Latin1_General_CS_AS,
  GrSAL nchar(10) COLLATE Latin1_General_CS_AS,
  GrWOZ nchar(10) COLLATE Latin1_General_CS_AS
)
*/
DECLARE @ImportFile nvarchar(200) = N'\\atenadvantex01\AdvanTex\Temp\Daten20190603.xlsx';  -- Pfad zum Excel-File mit den Teile-Daten. Muss für den SQL-Server-Prozess zugreifbar sein, daher am Besten unter \\atenadvantex01\advantex\temp\ ablegen.
DECLARE @XLSXImportSQL nvarchar(max);
/*
SET @XLSXImportSQL = N'SELECT CAST(PersID AS nchar(10)) AS PersID, ' +
  N'CAST(ArtNr AS nchar(3)) AS ArtNr, ' +
  N'CAST(ArtGr AS nchar(10)) AS ArtGr, ' +
  N'CAST(ArtMax AS int) AS ArtKredit ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [profil$]);';

INSERT INTO __DCSLKAmstettenProfil
EXEC sp_executesql @XLSXImportSQL;

SET @XLSXImportSQL = N'SELECT CAST(PersID AS nchar(10)) AS PersID, ' +
  N'CAST(MediumID AS nvarchar(25)) AS MediumID, ' +
  N'CAST(Nachname AS nvarchar(25)) AS Nachname, ' +
  N'CAST(Vorname AS nvarchar(20)) AS Vorname, ' +
  N'CAST(Anrede AS nvarchar(20)) AS Anrede ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [personal$]);';

INSERT INTO __DCSLKAmstettenPersonal
EXEC sp_executesql @XLSXImportSQL;

SET @XLSXImportSQL = N'SELECT CAST(ArtNr AS nchar(3)) AS ArtNr, ' +
  N'CAST(GrSAL AS nchar(10)) AS GrSAL, ' +
  N'CAST(GrWOZ AS nchar(10)) AS GrWOZ ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [GrMap$]);';

INSERT INTO __DCSLKAmstettenGRMap
EXEC sp_executesql @XLSXImportSQL;
*/

SELECT Personal.TraegerNr, Personal.Vorname, Personal.Nachname, Personal.PersID AS PersNr, Personal.Anrede, Personal.MediumID, Profil.ArtNr, Artikel.ArtikelBez, GrMap.GrWOZ, Profil.ArtKredit
FROM (
  SELECT x.*, 4 + ROW_NUMBER() OVER (ORDER BY x.Nachname, x.Vorname) AS TraegerNr
  FROM __DCSLKAmstettenPersonal AS x
) AS Personal
JOIN __DCSLKAmstettenProfil AS Profil ON Profil.PersID = Personal.PersID
JOIN __DCSLKAmstettenGRMap AS GrMap ON Profil.ArtNr = GrMap.ArtNr AND Profil.ArtGr = GrMap.GrSAL
JOIN Artikel ON Profil.ArtNr = Artikel.ArtikelNr
WHERE Personal.MediumID IS NOT NULL;

/*
DROP TABLE __DCSLKAmstettenGRMap;
DROP TABLE __DCSLKAmstettenProfil;
DROP TABLE __DCSLKAmstettenPersonal;
*/