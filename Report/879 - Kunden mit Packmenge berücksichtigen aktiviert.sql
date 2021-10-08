SELECT Firma.SuchCode AS Firma, Holding.Bez AS Holding, Branche.BrancheBez$LAN$ AS Branche, [Zone].ZonenCode AS Vertriebszone, Kunden.KdNr, Kunden.SuchCode AS Kunde
FROM Kunden
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Branche ON Kunden.BrancheID = Branche.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
WHERE Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1
  AND Kunden.FirmaID IN ($1$)
  AND Kunden.HoldingID IN ($2$)
  AND Kunden.BrancheID IN ($3$)
  AND Kunden.ZoneID IN ($4$)
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
  AND Kunden.CheckPackmenge = 1;