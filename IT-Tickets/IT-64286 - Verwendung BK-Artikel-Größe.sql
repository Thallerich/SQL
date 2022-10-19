DECLARE @ArticleSize TABLE (
  ArticleNumber nchar(15) COLLATE Latin1_General_CS_AS,
  ArticleSize nchar(10) COLLATE Latin1_General_CS_AS
);

INSERT INTO @ArticleSize
VALUES (N'0202', N'38'), (N'0202', N'56/055'), (N'0479', N'52/150'), (N'0802', N'52/170'), (N'4628', N'50/100'), (N'6002', N'52/150'), (N'01A1', N'36/065'), (N'01F4', N'40/040'), (N'01F4', N'48/040'), (N'01F4', N'48/060'), (N'01F4', N'52/040'), (N'01F4', N'56/040'), (N'01MU', N'44/100'), (N'01MU', N'44/110'), (N'01MU', N'60/105'), (N'01OL', N'L/100'), (N'01OL', N'M/100'), (N'01OL', N'S/100'), (N'01OL', N'XL/100'), (N'01OL', N'XS/100'), (N'01SI', N'M/040'), (N'02A1', N'40/060'), (N'02SI', N'L/050'), (N'02SI', N'S/050'), (N'02WK', N'L/040'), (N'02WK', N'S/040'), (N'04D2', N'48/150'), (N'04D2', N'52/150'), (N'04MU', N'40/100'), (N'04SJ', N'42/105'), (N'04SJ', N'44/105'), (N'04SJ', N'46/105'), (N'04SJ', N'48/095'), (N'04SJ', N'50/115'), (N'04SJ', N'52/095'), (N'04SJ', N'54/095'), (N'04SJ', N'56/095'), (N'04SJ', N'58/110'), (N'04SJ', N'60/110'), (N'04SJ', N'62/110'), (N'04SJ', N'64/110'), (N'04SJ', N'66/095'), (N'04SJ', N'66/110'), (N'06MU', N'40/105'), (N'06MU', N'48/110'), (N'06MU', N'48/115'), (N'06MU', N'60/120'), (N'06MV', N'60/115');

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Traeger.Traeger AS TrägerNr, Traeger.Vorname, Traeger.Nachname, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, TraeArti.Menge
FROM TraeArti
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN @ArticleSize AS ArticleSize ON Artikel.ArtikelNr = ArticleSize.ArticleNumber AND ArtGroe.Groesse = ArticleSize.ArticleSize;

GO