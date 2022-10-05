SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Kunden.Name1, Kunden.Name2, Kunden.Name3, Kunden.Land, Kunden.PLZ, Kunden.Ort, KdStufe.KdStufeBez$LAN$ AS Zufriedenheitsstufe, KdGf.KurzBez AS Geschäftsbereich, [Zone].ZonenCode AS Vertriebszone
FROM Kunden
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdStufe ON Kunden.KdStufeID = KdStufe.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
WHERE Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
  AND Firma.ID IN ($1$)
  AND KdGf.ID IN ($2$)
  AND [Zone].ID IN ($3$)
  AND KdStufe.ID IN ($4$);