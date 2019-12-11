SELECT Firma.SuchCode AS Firma, KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kunden.MindestumsatzTag AS [Mindestumsatz pro Liefertag], Kunden.MinMengeZuschTag AS [Zuschlag Unterschreitung Mindestumsatz]
FROM Kunden
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
WHERE Kunden.MindestumsatzTag <> 0
  AND Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1
  AND Kunden.ID > 0
  AND Kunden.StandortID = (SELECT ID FROM Standort WHERE SuchCode = N'UKLU');