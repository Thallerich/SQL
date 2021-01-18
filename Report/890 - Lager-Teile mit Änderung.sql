WITH Lagerstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TEILELAG')
)
SELECT Standort.SuchCode AS Lagerstandort, Lagerart.LagerartBez$LAN$ AS Lagerart, Lagerort.Lagerort, TeileLag.Barcode, Lagerstatus.StatusBez AS [Status], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, MassOrt.MassortBez$LAN$ AS Änderungsart, TeileLMa.Mass
FROM TeileLag
JOIN ArtGroe ON TeileLag.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Lagerart ON TeileLag.LagerArtID = Lagerart.ID
JOIN Standort ON Lagerart.LagerID = Standort.ID
JOIN Lagerort ON TeileLag.LagerOrtID = Lagerort.ID
JOIN TeileLMa ON TeileLMa.TeileLagID = TeileLag.ID
JOIN MassOrt ON TeileLMa.MassOrtID = MassOrt.ID
JOIN Lagerstatus ON TeileLag.[Status] = Lagerstatus.[Status]
WHERE Standort.ID IN ($1$)
  AND Lagerart.ID IN ($2$)
  AND TeileLag.Status IN (N'L', N'R')
ORDER BY Lagerstandort, Lagerart, Lagerort, Barcode, Änderungsart;