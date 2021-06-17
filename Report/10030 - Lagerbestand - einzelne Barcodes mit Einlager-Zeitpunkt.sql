SELECT TeileLag.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse AS Größe, TeileLag.Anlage_ AS [Zeitpunkt Einbuchung], Lagerart.LagerartBez$LAN$ AS Lagerart, Lagerart.Neuwertig, Lager.Bez AS Lagerstandort
FROM TeileLag
JOIN Lagerart ON TeileLag.LagerartID = Lagerart.ID
JOIN Standort AS Lager ON Lagerart.LagerID = Lager.ID
JOIN ArtGroe ON TeileLag.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
WHERE Lager.ID IN ($1$)
  AND TeileLag.Status IN (N'L', N'R');