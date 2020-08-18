SELECT [Zone].ZonenCode AS [Zone], Kunden.KdNr, Kunden.SuchCode AS Kunde, RwConfig.RwConfigBez AS [Restwertkonfiguration BK], PoolRwConfig.RwConfigBez AS [Restwertkonfiguration Pool-Flachwäsche]
FROM Kunden
JOIN RwConfig ON Kunden.RWConfigID = RwConfig.ID
JOIN RwConfig AS PoolRwConfig ON Kunden.RWPoolTeileConfigID = PoolRwConfig.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
WHERE Kunden.AdrArtID = 1
  AND Kunden.Status = N'A'
  AND [Zone].[ZonenCode] = N'SÜD';