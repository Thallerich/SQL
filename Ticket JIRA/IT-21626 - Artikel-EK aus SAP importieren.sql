DECLARE @ImportFile nvarchar(200) = N'\\atenadvantex01.wozabal.int\AdvanTex\Temp\EKPreis.xlsx';
DECLARE @XLSXImportSQL nvarchar(max);

DECLARE @ImportTable TABLE (
  Material nchar(20) COLLATE Latin1_General_CS_AS,
  EKPreis money
);

SET @XLSXImportSQL = N'SELECT CAST(Material AS nchar(20)) AS Material, ' +
  N'CAST(Materialpreis AS money) AS EKPreis ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [Tabelle1$]);';

INSERT INTO @ImportTable
EXEC sp_executesql @XLSXImportSQL;

WITH SAPArtikel AS (
  SELECT LEFT(Material, 4) AS ArtikelNr, MIN(EKPreis) AS EKPreis
  FROM @ImportTable
  GROUP BY LEFT(Material, 4)
)
--SELECT Artikel.ArtikelNr, Artikel.ArtikelBez, Artikel.EkPreis, SAPArtikel.ArtikelNr AS SAP_ArtikelNr, SAPArtikel.EKPreis AS SAP_EKPreis
UPDATE Artikel SET Artikel.EkPreis = SAPArtikel.EKPreis
FROM Artikel
JOIN SAPArtikel ON SAPArtikel.ArtikelNr = Artikel.ArtikelNr
WHERE SAPArtikel.EKPreis <> Artikel.EkPreis;

WITH SAPArtGroe AS (
  SELECT LEFT(Material, ABS(CHARINDEX(N'-', Material) - 1)) AS ArtikelNr, REPLACE(SUBSTRING(Material, CHARINDEX(N'-', Material) + 1, 20), N'/0', N'/') AS Groesse, EKPreis
  FROM @ImportTable
)
--SELECT Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, ArtGroe.EKPreis, SAPArtGroe.ArtikelNr AS SAP_ArtikelNr, SAPArtGroe.Groesse AS SAP_Groesse, SAPArtGroe.EKPreis AS SAP_EKPreis
UPDATE ArtGroe SET ArtGroe.EKPreis = SAPArtGroe.EKPreis
FROM ArtGroe
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN SAPArtGroe ON SAPArtGroe.ArtikelNr = Artikel.ArtikelNr AND SAPArtGroe.Groesse = ArtGroe.Groesse
WHERE SAPArtGroe.EKPreis <> ArtGroe.EKPreis;