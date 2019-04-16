SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, KdGf.KurzBez AS Geschäftsbereich, Firma.Bez AS Firma, Bereich.BereichBez AS Produktbereich, KdBer.RabattWasch AS [Rabatt Bearbeitung %], KdBer.RabattLeasing AS [Rabatt Leasing %]
FROM KdBer
JOIN Kunden ON KdBer.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
WHERE Kunden.Status = N'A'
  AND (KdBer.RabattWasch <> 0 OR KdBer.RabattLeasing <> 0);