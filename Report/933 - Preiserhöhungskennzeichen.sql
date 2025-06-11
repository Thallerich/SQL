SELECT AdrArt.AdrartBez AS [Kunden-Art], Firma.Bez AS Firma, Holding.Holding, KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr, Kunden.SuchCode AS Kunde, Standort.Bez AS Hauptstandort, Vertrag.VertragNr, Vertrag.Nr AS [eindeutige VertragsNr], PrLauf.PrLaufBez$LAN$ AS Preiserhöhungslauf, Vertrag.Preisgarantie AS [Preisgarantie bis], Vertrag.MaxPeProzent AS [maximale Preiserhöhung], Vertrag.LetztePeDatum AS [letzte Preiserhöhung], Vertrag.LetztePeProz AS [letzte Preiserhöhung in %]
FROM Vertrag
JOIN Kunden ON Vertrag.KundenID = Kunden.ID
JOIN AdrArt ON Kunden.AdrArtID = AdrArt.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN PrLauf ON Vertrag.PrLaufID = PrLauf.ID
WHERE Kunden.Status = N'A'
  AND Vertrag.Status = N'A'
  AND (
    ($1$ = 0 AND $2$ = 0 AND KdGf.Status = N'A' AND KdGf.KurzBez != N'INT')
    OR
    ($1$ = 1 AND $2$ = 0 AND Vertrag.PrLaufID < 0 AND EXISTS (SELECT 1 FROM KdBer WHERE KdBer.KundenID = Kunden.ID AND KdBer.VertragID = Vertrag.ID) AND KdGf.Status = N'A' AND KdGf.KurzBez != N'INT')
    OR
    ($1$ = 0 AND $2$ = 1 AND (Kunden.KdGfID < 0 OR KdGf.Status = N'I' OR KdGf.KurzBez = N'INT'))
    OR
    ($1$ = 1 AND $2$ = 1 AND ((Vertrag.PrLaufID < 0 AND EXISTS (SELECT 1 FROM KdBer WHERE KdBer.KundenID = Kunden.ID AND KdBer.VertragID = Vertrag.ID)) OR (Kunden.KdGfID < 0 OR KdGf.Status = N'I' OR KdGf.KurzBez = N'INT')))
  )
  AND Kunden.AdrArtID IN (1, 5)
  AND Kunden.FirmaID IN ($3$)
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
ORDER BY Kunden.KdNr;