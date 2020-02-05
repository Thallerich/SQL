SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, BestOrt.Bestand, BestOrt.Reserviert, Lagerort.Lagerort, LagerArt.LagerArtBez$LAN$ AS LagerArt
FROM BestOrt
JOIN Lagerort ON BestOrt.LagerOrtID = Lagerort.ID
JOIN Bestand ON BestOrt.BestandID = Bestand.ID
JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN LagerArt ON Bestand.LagerArtID = LagerArt.ID
WHERE LagerArt.LagerID = $1$
  AND BestOrt.Bestand > 0;