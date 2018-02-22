DECLARE @ArtNr nchar(15);
SET @ArtNr = N'209900010386';

SELECT OPTeile.Code, OPTeile.ArtGroeID, Teile.Barcode, Teile.ArtGroeID
FROM OPTeile
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
JOIN Teile ON Teile.OPTeileID = OPTeile.ID
WHERE Artikel.ArtikelNr = @ArtNr
  AND OPTeile.ArtGroeID < 0;

/*
UPDATE OPTeile SET ArtGroeID = Teile.ArtGroeID
FROM OPTeile
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
JOIN Teile ON Teile.OPTeileID = OPTeile.ID
WHERE Artikel.ArtikelNr = N'209900010386'
  AND OPTeile.ArtGroeID < 0
  AND Teile.ArtGroeID > 0;
*/

SELECT OPTeile.Code, OPTeile.ArtGroeID, OPTeile.LastScanTime
FROM OPTeile
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
WHERE Artikel.ArtikelNr = @ArtNr
  AND OPTeile.ArtGroeID < 0;

SELECT OPTeile.Code, OPTeile.ArtGroeID, Teile.Barcode, Teile.ArtGroeID, OPTeile.ArtikelID, Teile.ArtikelID
FROM OPTeile
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
JOIN Teile ON Teile.Barcode = OPTeile.Code
WHERE Artikel.ArtikelNr = @ArtNr
  AND OPTeile.ArtGroeID < 0
  AND OPTeile.ArtikelID = Teile.ArtikelID;

/*
UPDATE OPTeile SET ArtGroeID = Teile.ArtGroeID
FROM OPTeile
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
JOIN Teile ON Teile.Barcode = OPTeile.Code
WHERE Artikel.ArtikelNr = N'209900010386'
  AND OPTeile.ArtGroeID < 0
  AND OPTeile.ArtikelID = Artikel.ID;
*/

SELECT ArtGroe.*
FROM ArtGroe
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
WHERE Artikel.ArtikelNr = @ArtNr;

/*
UPDATE OPTeile SET ArtGroeID = 10297346
WHERE OPTeile.ArtikelID = (SELECT Artikel.ID FROM Artikel WHERE Artikel.ArtikelNr = N'209900010386')
  AND OPTeile.ArtGroeID < 0;
*/