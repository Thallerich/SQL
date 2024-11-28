SELECT EinzHist.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, EinzHist.Anlage_ AS [Zeitpunkt Einbuchung], Einzteil.Erstdatum as [Erstdatum], EinzTeil.RuecklaufG AS [Anzahl Wäschen], Lagerart.LagerartBez$LAN$ AS Lagerart, Lagerart.Neuwertig, Lager.Bez AS Lagerstandort, Lagerort.Lagerort, Kunden.KdNr AS [KdNr letzter Kunde], Kunden.SuchCode AS [letzter Kunde], EinzHist.RestwertInfo AS [Restwert in Lagerwährung], Firma.WaeID AS [Restwert in Lagerwährung_WaeID] , EinzTeil.AlterInfo AS [Alter in Wochen]
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN Lagerart ON EinzHist.LagerartID = Lagerart.ID
JOIN Standort AS Lager ON Lagerart.LagerID = Lager.ID
JOIN Firma ON Lagerart.FirmaID = Firma.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Kunden ON EinzHist.KundenID = Kunden.ID
JOIN Lagerort ON EinzHist.LagerortID = Lagerort.ID
WHERE Lager.ID IN ($1$)
AND Lagerart.ID IN ($2$)
  AND EinzHist.Status IN (N'X', N'XE')
  AND EinzHist.EinzHistTyp = 2;