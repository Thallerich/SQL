WITH Artikelstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'ARTIKEL')
)
SELECT Standort.Bez AS Lagerstandort, Lagerart.LagerartBez$LAN$ AS Lagerart, LagerArt.Neuwertig, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Artikelstatus.StatusBez AS Artikelstatus, ArtGroe.Groesse, Bestand.Bestand, Bestand.Reserviert, Bestand.BestandUrsprung AS [Bestand vom Ursprungsartikel], Bestand.Umlauf
FROM Bestand
JOIN Lagerart ON Bestand.LagerartID = Lagerart.ID
JOIN Standort ON Lagerart.LagerID = Standort.ID
JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Artikelstatus ON Artikel.Status = Artikelstatus.Status
WHERE Standort.ID = $1$
  AND Bestand.Bestand != 0
  AND (($2$ = 1 AND Lagerart.Neuwertig = 1) OR ($2$ = 0));