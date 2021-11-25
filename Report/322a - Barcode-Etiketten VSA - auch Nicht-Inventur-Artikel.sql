DECLARE @vsaid int = $ID$;

DECLARE @sqltext nvarchar(max);

SET @sqltext = N'SELECT Kunden.KdNr, Vsa.ID AS VsaID, Vsa.SuchCode, Kunden.Name1, Vsa.Bez, IIF(TRY_PARSE(Vsa.BarcodeNr AS bigint) IS NOT NULL, SUBSTRING(Vsa.BarcodeNr, 2, LEN(Vsa.BarcodeNr)), NULL) AS VsaBarcode, ISNULL(Artikel.BarcodeNr, Artikel.ArtikelNr + N''-'' + ArtGroe.Groesse) AS Artikelbarcode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbez
FROM VsaAnf
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON VsaAnf.ArtGroeID = ArtGroe.ID
WHERE Vsa.ID = @vsaid
ORDER BY VsaID, ArtikelNr;';

EXEC sp_executesql @sqltext, N'@vsaid int', @vsaid;