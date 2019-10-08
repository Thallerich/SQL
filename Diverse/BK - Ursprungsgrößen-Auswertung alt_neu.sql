WITH Altdaten AS (
  SELECT Artikel.ID AS ArtikelID, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.ID AS ArtGroeID, ArtGroe.Groesse AS [Größe], Ursprungsartikel.ID AS UrsprungsartikelID, Ursprungsartikel.ArtikelNr AS [Ursprungs-ArtikelNr], Ursprungsartikel.ArtikelBez AS [Ursprungs-Artikelbezeichnung], Ursprungsgroesse.ID AS UrsprungsgroesseID, Ursprungsgroesse.Groesse AS [Ursprungs-Größe]
  FROM [SRVATENADVTEST.WOZABAL.INT\ADVANTEX].Wozabal.dbo.Artikel
  JOIN [SRVATENADVTEST.WOZABAL.INT\ADVANTEX].Wozabal.dbo.ArtGroe ON ArtGroe.ArtikelID = Artikel.ID
  JOIN [SRVATENADVTEST.WOZABAL.INT\ADVANTEX].Wozabal.dbo.Artikel AS Ursprungsartikel ON Ursprungsartikel.ID = Artikel.BasisArtikelID AND Artikel.BasisArtikelID > 0
  JOIN [SRVATENADVTEST.WOZABAL.INT\ADVANTEX].Wozabal.dbo.ArtGroe AS Ursprungsgroesse ON Ursprungsgroesse.ID = ArtGroe.BasisArtGroeID AND ArtGroe.BasisArtGroeID > 0
)
SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS [Größe], Altdaten.Größe AS [alte Größe], Ursprungsartikel.ArtikelNr AS [Ursprungs-ArtikelNr], Ursprungsartikel.ArtikelBez AS [Ursprungs-Artikelbezeichnung], Ursprungsgroesse.Groesse AS [Ursprungs-Größe], Altdaten.[Ursprungs-Größe] AS [alte Ursprungs-Größe]
FROM Artikel
JOIN ArtGroe ON ArtGroe.ArtikelID = Artikel.ID
JOIN Artikel AS Ursprungsartikel ON Ursprungsartikel.ID = Artikel.BasisArtikelID AND Artikel.BasisArtikelID > 0
JOIN ArtGroe AS Ursprungsgroesse ON Ursprungsgroesse.ID = ArtGroe.BasisArtGroeID AND ArtGroe.BasisArtGroeID > 0
LEFT OUTER JOIN Altdaten ON Altdaten.ArtikelID = Artikel.ID AND Altdaten.ArtGroeID = ArtGroe.ID AND Altdaten.UrsprungsartikelID = Ursprungsartikel.ID AND Altdaten.UrsprungsgroesseID = Ursprungsgroesse.ID
WHERE ArtGroe.Groesse <> Altdaten.Größe;