SELECT EinzHist.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, EinzHist.Anlage_ AS [Zeitpunkt Einbuchung], Einzteil.Erstdatum as [Erstdatum], EinzTeil.RuecklaufG AS [Anzahl Wäschen], Lagerart.LagerartBez$LAN$ AS Lagerart, Lagerart.Neuwertig, Lager.Bez AS Lagerstandort, Lagerort.Lagerort, IIF(Kunden.ID = -1, NULL, Kunden.KdNr) AS [KdNr letzter Kunde], Kunden.SuchCode AS [letzter Kunde], COALESCE(IIF(Restwert.Restwertinfo = 0, NULL, Restwert.RestwertInfo), EinzHist.RestwertInfo) AS [Restwert in Lagerwährung], Firma.WaeID AS [Restwert in Lagerwährung_WaeID] , EinzTeil.AlterInfo AS [Alter in Wochen], CAST(IIF(EXISTS(SELECT TeilAppl.ID FROM TeilAppl WHERE TeilAppl.EinzHistID = EinzHist.ID), 1, 0) AS bit) [mit Applikation]
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
OUTER APPLY advfunc_GetRestwertIgnoreAusdRestW(EinzHist.ID, (SELECT [Week].Woche FROM [Week] WHERE CAST(GETDATE() AS date) BETWEEN [Week].VonDat AND [Week].BisDat), 1) AS Restwert
JOIN Lagerart ON EinzHist.LagerartID = Lagerart.ID
JOIN Standort AS Lager ON Lagerart.LagerID = Lager.ID
JOIN Firma ON Lagerart.FirmaID = Firma.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Kunden ON EinzHist.KundenID = Kunden.ID
JOIN Lagerort ON EinzHist.LagerortID = Lagerort.ID
WHERE Lagerart.ID IN ($2$)
  AND EinzHist.Status IN (N'X', N'XE')
  AND EinzHist.EinzHistTyp = 2;