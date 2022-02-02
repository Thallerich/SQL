SELECT TeileLag.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse AS Größe, TeileLag.Anlage_ AS [Zeitpunkt Einbuchung], Lagerart.LagerartBez$LAN$ AS Lagerart, Lagerart.Neuwertig, Lager.Bez AS Lagerstandort, Lagerort.Lagerort, Kunden.KdNr AS [KdNr letzter Kunde], Kunden.SuchCode AS [letzter Kunde]
FROM TeileLag
JOIN Lagerart ON TeileLag.LagerartID = Lagerart.ID
JOIN Standort AS Lager ON Lagerart.LagerID = Lager.ID
JOIN ArtGroe ON TeileLag.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Kunden ON TeileLag.KundenID = Kunden.ID
JOIN Lagerort ON TeileLag.LagerortID = Lagerort.ID
WHERE Lager.ID IN ($1$)
  AND TeileLag.Status IN (N'L', N'R');