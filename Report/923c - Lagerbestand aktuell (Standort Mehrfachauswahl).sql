WITH Artikelstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'ARTIKEL')
)
SELECT Standort.Bez AS Lagerstandort, Lagerort.Lagerort, LagSchr.Bez AS Lagerschrank, Lagerart.LagerartBez$LAN$ AS Lagerart, LagerArt.Neuwertig, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Artikelstatus.StatusBez AS Artikelstatus, Lief.LiefNr AS [Lieferant Nr.], Lief.SuchCode AS [Lieferant Stichwort], ArtGroe.Groesse, BestOrt.Bestand, BestOrt.Reserviert, BestOrt.BestandUrsprung AS [Bestand vom Ursprungsartikel]
, IIF(ArtGroe.ID > 0, ArtGroe.EKPreis, Artikel.EKPreis) AS EkPreis
FROM Lagerort
JOIN Standort ON Lagerort.LagerID = Standort.ID
JOIN LagSchr ON Lagerort.LagSchrID = LagSchr.ID
JOIN BestOrt ON BestOrt.LagerortID = Lagerort.ID
JOIN Bestand ON BestOrt.BestandID = Bestand.ID
JOIN Lagerart ON Bestand.LagerartID = Lagerart.ID
JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Artikelstatus ON Artikel.Status = Artikelstatus.Status
JOIN Lief ON Artikel.LiefID = Lief.ID
WHERE Standort.ID in ($1$)
  AND BestOrt.Bestand != 0
  AND (($2$ = 1 AND Lagerart.Neuwertig = 1) OR ($2$ = 0));