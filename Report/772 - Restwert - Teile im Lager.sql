WITH LagerteilStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZHIST'
)
SELECT Lager.Suchcode AS [Lager-Standort], Lagerart.LagerartBez$LAN$ AS Lagerart, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, IIF(Kunden.KdNr = 0, NULL, Kunden.KdNr) AS [Letzte KdNr], Kunden.SuchCode AS [Letzter Kunde], EinzHist.Barcode, LagerteilStatus.StatusBez AS [Status Lager-Teil], Lagerort.Lagerort, VertragWaeRestwert.NachPreis AS Restwert, Wae.IsoCode AS Währung
FROM EinzHist
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
JOIN Lagerart ON EinzHist.LagerArtID = Lagerart.ID
JOIN Firma ON Lagerart.FirmaID = Firma.ID
JOIN Standort AS Lager ON Lagerart.LagerID = Lager.ID
JOIN Lagerort ON EinzHist.LagerOrtID = Lagerort.ID
JOIN Kunden ON EinzHist.KundenID = Kunden.ID
JOIN Wae ON Kunden.VertragWaeID = Wae.ID
JOIN LagerteilStatus ON EinzHist.[Status] = LagerteilStatus.[Status]
CROSS APPLY dbo.advFunc_ConvertExchangeRate(Firma.WaeID, Kunden.VertragWaeID, EinzHist.RestwertInfo, GETDATE()) AS VertragWaeRestwert
WHERE EinzHist.EinzHistTyp = 2 /* Teile im Lager */
  AND EinzHist.[Status] IN (N'X', N'XE', N'XI')
  AND Lager.ID IN ($1$);