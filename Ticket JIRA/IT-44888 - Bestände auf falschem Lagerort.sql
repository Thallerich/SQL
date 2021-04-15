SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Lagerort.Lagerort, Lager.Bez AS [Lagerort-Standort], Lagerart.Lagerart, LLager.Bez AS [Lagerart-Standort]
FROM Bestand
JOIN BestOrt ON BestOrt.BestandID = Bestand.ID
JOIN Lagerart ON Bestand.LagerartID = Lagerart.ID
JOIN Standort AS LLager ON Lagerart.LagerID = LLager.ID
JOIN Lagerort ON BestOrt.LagerortID = Lagerort.ID
JOIN Standort AS Lager ON Lagerort.LagerID = Lager.ID
JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN GroePo ON GroePo.Groesse = ArtGroe.Groesse AND GroePo.GroeKoID = Artikel.GroeKoID
WHERE BestOrt.LagerOrtID IN (
    SELECT Lagerort.ID
    FROM Lagerort
    WHERE Lagerort.LagerID = (SELECT ID FROM Standort WHERE Bez = N'Linz')
      AND LEFT(Lagerort.Lagerort, 1) = N'R'
  )
  AND BestOrt.Bestand != 0
ORDER BY Artikel.ArtikelNr, GroePo.Folge;