-- Barcode, ArtikelNr, Artikelbezeichnung, Größe, Zeitpunkt Einbuchung
SELECT TeileLag.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse AS Größe, TeileLag.Anlage_ AS [Zeitpunkt Einbuchung], Lagerart.LagerartBez, Lagerart.Neuwertig
FROM TeileLag
JOIN Lagerart ON TeileLag.LagerartID = Lagerart.ID
JOIN Standort AS Lager ON Lagerart.LagerID = Lager.ID
JOIN ArtGroe ON TeileLag.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
WHERE Lager.SuchCode = N'BRAT'
  AND TeileLag.Status IN (N'L', N'R');