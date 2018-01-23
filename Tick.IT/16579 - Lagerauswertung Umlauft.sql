SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, Artikel.EKPreis, Bestand.Bestand, LagerOrt.Bez AS Lagerort, LagerArt.Neuwertig AS Neuware, Bestand.LetzteBewegung, Lief.LiefNr AS LieferantenNr, Lief.SuchCode AS Lieferant, Lief.Name1, Lief.Name2, Lief.Name3
FROM BestOrt, Bestand, LagerOrt, LagerArt, ArtGroe, Artikel, Lief
WHERE BestOrt.BestandID = Bestand.ID
  AND BestOrt.LagerOrtID = LagerOrt.ID
  AND Bestand.LagerArtID = LagerArt.ID
  AND Bestand.ArtGroeID = ArtGroe.ID
  AND ArtGroe.ArtikelID = Artikel.ID
  AND Artikel.LiefID = Lief.ID
  AND LagerArt.LagerID = 5001 -- Lagerstandort Umlauft
  AND BestOrt.Bestand > 0;