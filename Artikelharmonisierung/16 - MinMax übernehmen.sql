UPDATE Bestand SET Minimum = BestandAlt.Minimum, Maximum = BestandAlt.Maximum
FROM Bestand
JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN __ArtikelMapping ON Artikel.ArtikelNr = __ArtikelMapping.ArtikelNrNeu
JOIN Artikel AS ArtikelAlt ON __ArtikelMapping.ArtikelNrAlt = ArtikelAlt.ArtikelNr
JOIN ArtGroe AS ArtGroeAlt ON ArtikelAlt.ID = ArtGroeAlt.ArtikelID
JOIN Bestand AS BestandAlt ON BestandAlt.ArtGroeID = ArtGroeAlt.ID AND Bestand.LagerArtID = BestandAlt.LagerArtID
WHERE (Bestand.Minimum != BestandAlt.Minimum OR Bestand.Maximum != BestandAlt.Maximum);