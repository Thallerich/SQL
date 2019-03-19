DECLARE @ImportFile nvarchar(200) = N'\\atenadvantex01\AdvanTex\Temp\LKScheibbsDCS.xlsx';
DECLARE @XLSXImportSQL nvarchar(max);

DECLARE @ImportTablePersonal TABLE (
  PersID nvarchar(10) COLLATE Latin1_General_CS_AS,
  MediumID nchar(6) COLLATE Latin1_General_CS_AS,
  Nachname nvarchar(50) COLLATE Latin1_General_CS_AS,
  Vorname nvarchar(50) COLLATE Latin1_General_CS_AS,
  Anrede nvarchar(50) COLLATE Latin1_General_CS_AS,
  Kredit int,
  DelFlg smallint
);

DECLARE @ImportTableArtikelprofil TABLE (
  PersID nvarchar(10) COLLATE Latin1_General_CS_AS,
  ArtNr nchar(3) COLLATE Latin1_General_CS_AS,
  ArtGr nchar(10) COLLATE Latin1_General_CS_AS,
  DelFlg smallint
);

SET @XLSXImportSQL = N'SELECT CAST(PersID AS nvarchar(10)), ' +
  N'CAST(MediumID AS nchar(6)), ' +
  N'CAST(Nachname AS nvarchar(50)), ' +
  N'CAST(Vorname AS nvarchar(50)), ' +
  N'CAST(Anrede AS nvarchar(50)), ' +    
  N'CAST(Kredit AS int), ' +
  N'CAST(DelFlg AS smallint) ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [Personal$]);';

INSERT INTO @ImportTablePersonal
EXEC sp_executesql @XLSXImportSQL;

SET @XLSXImportSQL = N'SELECT CAST(PersID AS nvarchar(10)), ' +
  N'CAST(ArtNr AS nchar(3)), ' +
  N'CAST(ArtGr AS nchar(3)), ' +
  N'CAST(DelFlg AS smallint) ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [Artikelprofil$]);';

INSERT INTO @ImportTableArtikelprofil
EXEC sp_executesql @XLSXImportSQL;

UPDATE @ImportTableArtikelprofil SET ArtGr = N'L-95' WHERE ArtGr = N'L0';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'XXS-105' WHERE ArtGr = N'2S2';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'3XL-105' WHERE ArtGr = N'3X2';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'S-105' WHERE ArtGr = N'S2';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'XL-105' WHERE ArtGr = N'XL2';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'XL-115' WHERE ArtGr = N'XL4';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'XS-105' WHERE ArtGr = N'XS2';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'XXL-105' WHERE ArtGr = N'XX2';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'XXS-95' WHERE ArtGr = N'2S0';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'XXS-100' WHERE ArtGr = N'2S1';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'XXS-90' WHERE ArtGr = N'2S8';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'3XL-100' WHERE ArtGr = N'3X1';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'S-95' WHERE ArtGr = N'S0';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'S-100' WHERE ArtGr = N'S1';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'S-110' WHERE ArtGr = N'S3';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'S-115' WHERE ArtGr = N'S4';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'S-90' WHERE ArtGr = N'S8';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'XL-95' WHERE ArtGr = N'XL0';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'XL-100' WHERE ArtGr = N'XL1';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'XL-110' WHERE ArtGr = N'XL3';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'XS-95' WHERE ArtGr = N'XS0';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'XS-100' WHERE ArtGr = N'XS1';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'XS-90' WHERE ArtGr = N'XS8';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'XXL-95' WHERE ArtGr = N'XX0';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'XXL-100' WHERE ArtGr = N'XX1';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'XXL-110' WHERE ArtGr = N'XX3';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'XS-110' WHERE ArtGr = N'XS3';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'6XL' WHERE ArtGr = N'6X';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'L-100' WHERE ArtGr = N'L1';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'M-95' WHERE ArtGr = N'M0';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'M-100' WHERE ArtGr = N'M1';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'L-105' WHERE ArtGr = N'L2';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'M-105' WHERE ArtGr = N'M2';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'3XL' WHERE ArtGr = N'3X';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'4XL' WHERE ArtGr = N'4X';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'XXL' WHERE ArtGr = N'XX';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'XXS' WHERE ArtGr = N'2S';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'5XL' WHERE ArtGr = N'5X';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'L-110' WHERE ArtGr = N'L3';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'M-110' WHERE ArtGr = N'M3';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'6XL' WHERE ArtGr = N'6X';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'M-90' WHERE ArtGr = N'M8';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'XL-90' WHERE ArtGr = N'XL8';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'XXS-110' WHERE ArtGr = N'2S3';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'5XL' WHERE ArtGr = N'5X';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'M-115' WHERE ArtGr = N'M4';
UPDATE @ImportTableArtikelprofil SET ArtGr = N'L-90' WHERE ArtGr = N'L8';

UPDATE @ImportTableArtikelprofil SET ArtGr = REPLACE(ArtGr, N'-', N'/') WHERE ArtNr IN (N'F41', N'F91');
UPDATE @ImportTableArtikelprofil SET ArtGr = LEFT(ArtGr, CHARINDEX(N'-', ArtGr) - 1) WHERE ArtNr = N'F92';

WITH DCSData AS (
  SELECT Personal.PersID, Personal.MediumID, Personal.Nachname, Personal.Vorname, Personal.Anrede, Personal.Kredit, Personal.DelFlg AS DeletePerson, Artikelprofil.ArtNr, Artikelprofil.ArtGr, Artikelprofil.DelFlg AS DeleteProfil
  FROM @ImportTablePersonal AS Personal
  JOIN @ImportTableArtikelprofil AS Artikelprofil ON Artikelprofil.PersID = Personal.PersID
  WHERE (Personal.DelFlg = -1 OR Artikelprofil.DelFlg = -1)
)
DELETE FROM TraeArti WHERE ID IN (
  SELECT TraeArti.ID
  FROM TraeArti
  JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
  JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
  JOIN DCSData ON DCSData.ArtNr = Artikel.ArtikelNr AND DCSData.ArtGr = ArtGroe.Groesse AND DCSData.PersID = Traeger.PersNr AND DCSData.MediumID = Traeger.RentomatKarte
  WHERE Kunden.KdNr = 10001662
    AND Vsa.VsaNr = 1
);