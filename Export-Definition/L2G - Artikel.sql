SELECT Artikel.ArtikelNr AS ARTIKLENR, ARtikel.ArtikelBez AS DE, Artikel.ArtikelBez1 AS EN, Artikel.ArtikelBez3 AS RO, ArtGru.ArtGruBez AS ARTGRUPPE, Artikel.PackMenge AS PACKMENGE
FROM Artikel
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
WHERE Artikel.ArtikelNr LIKE N'L2G%';