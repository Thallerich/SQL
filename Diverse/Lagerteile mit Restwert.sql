USE Salesianer
GO

WITH LagerteilStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TeileLag')
)
SELECT Standort.Bez AS Lagerstandort, LagerArt.LagerartBez AS Lagerart, TeileLag.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS [Größe], LagerteilStatus.StatusBez AS [Status Lager-Teil], IIF(Lagerart.Neuwertig = 1, NULL, TeileLag.ErstDatum) AS [Erste Auslieferung zu erstem Kunden], IIF(Lagerart.Neuwertig = 1, 0, DATEDIFF(week, TeileLag.ErstDatum, DATEADD(day, TeileLag.AnzTageImLager * -1, GETDATE()))) AS [Alter in Wochen abzüglich Zeit im Lager], IIF(Lagerart.Neuwertig = 1, NULL, Kunden.KdNr) AS [KdNr letzter Kunde], IIF(Lagerart.Neuwertig = 1, NULL, Kunden.SuchCode) AS [letzter Kunde]
FROM TeileLag
JOIN ArtGroe ON TeileLag.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN LagerteilStatus ON TeileLag.[Status] = LagerteilStatus.[Status]
JOIN LagerArt ON TeileLag.LagerArtID = LagerArt.ID
JOIN Firma ON Lagerart.FirmaID = Firma.ID
JOIN Standort ON LagerArt.LagerID = Standort.ID
JOIN Kunden ON TeileLag.KundenID = Kunden.ID
WHERE TeileLag.Status < N'Y'
  AND TeileLag.ArtGroeID > 0
  AND Artikel.ArtikelNr IN (N'01AU', N'01AV', N'01S9', N'01SO', N'01V1', N'01V3', N'01VN', N'04AU', N'04S9', N'04SO', N'04V2', N'04VN', N'04VW', N'05AU', N'05AV', N'3522003823', N'05S9', N'05SO', N'05V1', N'05V2', N'05V3', N'05VN', N'05VW', N'06AU', N'06AV', N'3522003824', N'06S9', N'06SO', N'06V1', N'06V3', N'06VN', N'06VW', N'24V3', N'06PS', N'05PP', N'06PO', N'05PO', N'04PS', N'05SD', N'06SD', N'70P6', N'03PO')
  AND Firma.SuchCode = N'FA14';

GO