SELECT *
FROM (
  SELECT Lager.SuchCode AS Lagerstandort, Lagerart.Lagerart, Lagerart.LagerartBez, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse AS Größe, LagerBew.ID AS TransactionID, LagerBew.Zeitpunkt, LgBewCod.Code AS Bewegungscode, LgBewCod.LgBewCodBez AS BewegungscodeBez, LagerBew.BestandNeu - LagerBew.Differenz AS BestandAlt, LagerBew.Differenz AS Bewegung, LagerBew.BestandNeu, DENSE_RANK() OVER (PARTITION BY LagerBew.LgBewCodID ORDER BY LagerBew.ID DESC) AS TopRank
  FROM LagerBew
  JOIN Bestand ON LagerBew.BestandID = Bestand.ID
  JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
  JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
  JOIN Lagerart ON Bestand.LagerArtID = Lagerart.ID
  JOIN Standort AS Lager ON Lagerart.LagerID = Lager.ID
  JOIN LgBewCod ON LagerBew.LgBewCodID = LgBewCod.ID
  WHERE Artikel._IsHAWA = 1
    AND Lagerart.FirmaID = 5260
    AND Lagerart.BestandZu = 0
    AND LagerBew.Differenz != 0
    AND LagerBew.Zeitpunkt > N'2020-04-01 00:00:00'
    AND LagerBew.Zeitpunkt < DATEADD(day, -1, GETDATE())
    AND LgBewCod.Code != N'IN??'
) AS x
WHERE x.TopRank <= 10;