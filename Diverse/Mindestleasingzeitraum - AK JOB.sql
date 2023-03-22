SELECT Firma.SuchCode AS Firma, KdGf.KurzBez AS Geschäftsbereich, [Zone].ZonenCode AS Vertriebszone, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kunden.MinLeasWochen AS [Mindestleasing in Wochen]
FROM Kunden
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
WHERE Kunden.AdrArtID = 1
  AND Kunden.Status = N'A'
  AND Kunden.MinLeasWochen > 0
  AND Firma.SuchCode = N'FA14'
  AND KdGf.KurzBez = N'JOB';

GO