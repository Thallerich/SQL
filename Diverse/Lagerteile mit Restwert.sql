USE Wozabal
GO

SELECT RTRIM(Standort.Bez) AS Lagerstandort, RTRIM(LagerArt.LagerartBez) AS Lagerart, RTRIM(TeileLag.Barcode) AS Barcode, RTRIM(Artikel.ArtikelNr) AS ArtikelNr, RTRIM(Artikel.ArtikelBez) AS Artikelbezeichnung, RTRIM(ArtGroe.Groesse) AS [Größe], RTRIM(Status.StatusBez) AS Teilestatus, FORMAT(TeileLag.Restwert, 'C', 'de-AT') AS [Restwert bei Einlagerung], Teile.AlterInfo AS [Alter des Teils in Wochen], TeileLag.ErstWoche, TeileLag.AnzWaschen AS [Anzahl Wäschen], FORMAT(TeileLag.ErstDatum, 'd', 'de-at') AS [Erste Auslieferung]
FROM TeileLag
LEFT OUTER JOIN Teile ON TeileLag.Barcode = Teile.Barcode
JOIN ArtGroe ON TeileLag.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Status ON TeileLag.Status = Status.Status AND Status.Tabelle = N'TEILELAG'
JOIN LagerArt ON TeileLag.LagerArtID = LagerArt.ID
JOIN Standort ON LagerArt.LagerID = Standort.ID
WHERE TeileLag.Status < N'X'
AND TeileLag.ArtGroeID > 0

GO