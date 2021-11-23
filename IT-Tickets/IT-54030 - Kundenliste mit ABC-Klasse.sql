SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Holding.Holding, ABC.ABCBez AS [ABC-Klasse], KdGf.KurzBez AS Geschäfsfeld
FROM Kunden
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Abc ON Kunden.AbcID = Abc.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
WHERE Firma.SuchCode = N'FA14'
  AND Kunden.AdrArtID = 1
  AND Kunden.Status = N'A';