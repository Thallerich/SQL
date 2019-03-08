DECLARE @Stichtag date = N'2019-03-01';

SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Standort.Bez AS Lagerstandort, LagerBew.Differenz AS Lagerbewegungsmenge, LagerBew.Zeitpunkt AS Lagerbewegungszeitpunkt, LgBewCod.LgBewCodBez AS Lagerbewegungscode, LagerArt.Neuwertig AS Neuware
FROM LagerBew
JOIN Bestand ON LagerBew.BestandID = Bestand.ID
JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN LagerArt ON Bestand.LagerArtID = LagerArt.ID
JOIN Standort ON LagerArt.LagerID = Standort.ID
JOIN LgBewCod ON LagerBew.LgBewCodID = LgBewCod.ID
WHERE Standort.SuchCode = N'WOLE'
  AND Artikel.ID > 0
  AND LagerBew.Zeitpunkt >= DATEADD(year, -1, @Stichtag)
  AND LagerBew.Zeitpunkt < @Stichtag
ORDER BY Lagerbewegungszeitpunkt ASC;