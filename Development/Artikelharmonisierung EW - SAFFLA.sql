DECLARE @ArtiMapEW TABLE (
  ArtikelIDAlt int,
  ArtikelNrAlt nchar(15) COLLATE Latin1_General_CS_AS,
  ArtikelIDNeu int,
  ArtikelNrNeu nchar(15) COLLATE Latin1_General_CS_AS
);

INSERT INTO @ArtiMapEW (ArtikelNrAlt, ArtikelNrNeu)
VALUES (N'191406610000', N'192406610000'), (N'191400120000', N'192400120000'), (N'191406260000', N'192406260000'), (N'191403020000', N'192403020000'), (N'191406380000', N'192406380000'), (N'191406520000', N'192406520000'), (N'191406510100', N'192406510100'), (N'191403060000', N'192403060000'), (N'191403070000', N'192403070000'), (N'191403130000', N'192403130000'), (N'194406930000', N'192406930000'), (N'191403260000', N'192403260000'), (N'191403280000', N'192403280000'), (N'191403270000', N'192403270000'), (N'191409320000', N'192409320001'), (N'492403440000', N'192403440000'), (N'191406820000', N'192403091000'), (N'114470025150', N'114470025050'), (N'114470025170', N'114470025070');

UPDATE ArtiMapEW SET ArtikelIDAlt = Artikel.ID
FROM @ArtiMapEW ArtiMapEW
JOIN Artikel ON ArtiMapEW.ArtikelNrAlt = Artikel.ArtikelNr;

UPDATE ArtiMapEW SET ArtikelIDNeu = Artikel.ID
FROM @ArtiMapEW ArtiMapEW
JOIN Artikel ON ArtiMapEW.ArtikelNrNeu = Artikel.ArtikelNr;

IF OBJECT_ID(N'Salesianer.dbo._EWTeileForCIT') IS NULL
  CREATE TABLE Salesianer.dbo._EWTeileForCIT (
    OPTeileID int
  );

WITH Teileudpate AS (
  SELECT OPTeile.ID AS OPTeileID, ArtiMapEW.ArtikelIDNeu, ArtGroeNeu.ID AS ArtGroeIDNeu
  FROM OPTeile
  JOIN ArtGroe ON OPTeile.ArtGroeID = ArtGroe.ID
  JOIN @ArtiMapEW AS ArtiMapEW ON ArtiMapEW.ArtikelIDAlt = OPTeile.ArtikelID
  JOIN ArtGroe AS ArtGroeNeu ON ArtGroeNeu.ArtikelID = ArtiMapEW.ArtikelIDNeu AND ArtGroeNeu.Groesse = ArtGroe.Groesse
)
UPDATE OPTeile SET ArtikelID = Teileudpate.ArtikelIDNeu, ArtGroeID = Teileudpate.ArtGroeIDNeu
OUTPUT inserted.ID
INTO _EWTeileForCIT (OPTeileID)
FROM Teileudpate
WHERE Teileudpate.OPTeileID = OPTeile.ID;

GO