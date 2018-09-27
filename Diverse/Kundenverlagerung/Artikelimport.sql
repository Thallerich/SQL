DECLARE @ImportFile nvarchar(200) = N'\\atenadvantex01\AdvanTex\Temp\SAL_Artikel.xlsx';  -- Pfad zum Excel-File mit den Teile-Daten. Muss für den SQL-Server-Prozess zugreifbar sein, daher am Besten unter \\atenadvantex01\advantex\temp\ ablegen.
DECLARE @XLSXImportSQL nvarchar(max);

DECLARE @SalArtikel TABLE (
  Bereich nchar(2) COLLATE Latin1_General_CS_AS,
  Artikelgruppe nchar(4) COLLATE Latin1_General_CS_AS,
  ArtikelNr nvarchar(15) COLLATE Latin1_General_CS_AS,
  ArtikelBez nvarchar(60) COLLATE Latin1_General_CS_AS,
  Groesse nvarchar(15) COLLATE Latin1_General_CS_AS
);

SET @XLSXImportSQL = N'SELECT CAST(AKTIVITÄT AS nchar(2)) AS Bereich, ' +
  N'CAST(PRODUKTGRUPPE AS nchar(4)) AS Artikelgruppe, ' +
  N'CAST(ArtikelNr AS nvarchar(15)) AS ArtikelNr, ' +
  N'CAST(ArtikelBez AS nvarchar(60)) AS Artikelbezeichnung, ' +
  N'CAST(GroesseKorrigiert AS nvarchar(15)) AS Groesse ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [Artikel$]);';

INSERT INTO @SalArtikel
EXEC sp_executesql @XLSXImportSQL;

INSERT INTO Artikel (ArtiTypeID, [Status], ArtikelNr, ArtikelBez, ArtikelBez1, ArtikelBez2, SuchCode, BereichID, LiefID, LiefTageID, ArtGruID, MeID, LiefArtID, PackMenge, SichtbarID, KontenID)
SELECT DISTINCT 1 AS ArtiTypeID, N'A' AS [Status], SalArtikel.ArtikelNr, SalArtikel.ArtikelBez, SalArtikel.ArtikelBez AS ArtikelBez1, SalArtikel.ArtikelBez AS ArtikelBez2, LEFT(SalArtikel.ArtikelBez, 20) AS SuchCode, Bereich.ID AS BereichID, 190 AS LiefID, 190 AS LiefTageID, ArtGru.ID AS ArtGruID, 1 AS MeID, 4 AS LiefArtID, 1 AS Packmenge, -2 AS SichtbarID, 564 AS KontenID
FROM @SalArtikel AS SalArtikel
JOIN Bereich ON SalArtikel.Bereich = Bereich.Bereich
JOIN ArtGru ON SalArtikel.Artikelgruppe = ArtGru.Gruppe AND ArtGru.BereichID = Bereich.ID
WHERE NOT EXISTS (
  SELECT Artikel.ID
  FROM Artikel
  WHERE Artikel.ArtikelNr = SalArtikel.ArtikelNr
);

INSERT INTO ArtGroe (ArtikelID, Groesse, [Status])
SELECT Artikel.ID AS ArtikelID, SalArtikel.Groesse, N'A' AS [Status]
FROM @SalArtikel AS SalArtikel
JOIN Artikel ON SalArtikel.ArtikelNr = Artikel.ArtikelNr
WHERE NOT EXISTS (
  SELECT ArtGroe.ID
  FROM ArtGroe
  WHERE ArtGroe.ArtikelID = Artikel.ID AND ArtGroe.Groesse = SalArtikel.Groesse
);