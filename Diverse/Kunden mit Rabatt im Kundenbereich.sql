USE Wozabal;

SELECT KdGf.KurzBez AS SGF, Kunden.KdNr, Kunden.SuchCode AS Kunde, Bereich.BereichBez AS Produktbereich, KdBer.RabattLeasing AS [Leasing-Rabatt %], KdBer.RabattWasch AS [Bearbeitung-Rabatt %]
FROM KdBer
JOIN Kunden ON KdBer.KundenID = Kunden.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
WHERE Kunden.Status = N'A'
  AND (KdBer.RabattLeasing <> 0 OR KdBer.RabattWasch <> 0)
  AND KdGf.KurzBez = N'HO';