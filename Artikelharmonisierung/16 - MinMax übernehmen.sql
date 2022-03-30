UPDATE Bestand SET Minimum = BestandAlt.Minimum, Maximum = BestandAlt.Maximum
FROM Bestand
JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN __ArtiMapKentaur20220309 ON Artikel.ArtikelNr = __ArtiMapKentaur20220309.ArtikelNrNeu
JOIN Artikel AS ArtikelAlt ON __ArtiMapKentaur20220309.ArtikelNrAlt = ArtikelAlt.ArtikelNr
JOIN ArtGroe AS ArtGroeAlt ON ArtikelAlt.ID = ArtGroeAlt.ArtikelID
JOIN Bestand AS BestandAlt ON BestandAlt.ArtGroeID = ArtGroeAlt.ID AND Bestand.LagerArtID = BestandAlt.LagerArtID
WHERE (Bestand.Minimum != BestandAlt.Minimum OR Bestand.Maximum != BestandAlt.Maximum);