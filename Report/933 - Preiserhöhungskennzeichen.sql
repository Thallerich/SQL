SELECT Firma.Bez AS Firma, Holding.Holding, KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr, Kunden.SuchCode AS Kunde, Standort.Bez AS Hauptstandort, Vertrag.VertragNr, PrLauf.PrLaufBez$LAN$ AS Preiserhöhungslauf, Vertrag.Preisgarantie AS [Preisgarantie bis], Vertrag.MaxPeProzent AS [maximale Preiserhöhung], Vertrag.LetztePeDatum AS [letzte Preiserhöhung], Vertrag.LetztePeProz AS [letzte Preiserhöhung in %]
FROM Vertrag
JOIN Kunden ON Vertrag.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN PrLauf ON Vertrag.PrLaufID = PrLauf.ID
WHERE Kunden.Status = N'A'
  AND Vertrag.Status = N'A'
  AND (($1$ = 1 AND Vertrag.PrLaufID < 0) OR ($1$ = 0))
  AND Kunden.AdrArtID = 1
  AND KdGf.Status = N'A'
  AND KdGf.KurzBez <> N'INT'
ORDER BY Kunden.KdNr;