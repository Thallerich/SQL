SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Lager.Bez AS Lagerstandort, Lagerart.LagerartBez AS Lagerart, Lagerort.Lagerort, BestOrt.Bestand
FROM BestOrt
JOIN Lagerort ON BestOrt.LagerOrtID = Lagerort.ID
JOIN Bestand ON BestOrt.BestandID = Bestand.ID
JOIN Lagerart ON Bestand.LagerArtID = Lagerart.ID
JOIN Standort AS Lager ON Lagerart.LagerID = Lager.ID
JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN GroePo ON Artikel.GroeKoID = GroePo.GroeKoID AND ArtGroe.Groesse = GroePo.Groesse
WHERE Artikel.ArtikelNr IN (N'3630010138', N'3630010184', N'3630010139', N'3630010104', N'3630010097', N'3630010087', N'3630010085', N'3630010086', N'3630010077', N'3630010078', N'3630010079', N'3630010080', N'3050000001', N'3630010081', N'3630010083', N'3630010185', N'3140113003', N'3150113002', N'4001000000', N'3630010186', N'4007030001', N'3296071814', N'3296071814', N'3630010186', N'3296071812')
  AND BestOrt.Bestand != 0
  AND Lager.SuchCode != N'SMZL'
  AND Lager.SuchCode != N'GASS'
ORDER BY ArtikelNr, GroePo.Folge, Lagerstandort, Lagerart, Lagerort;