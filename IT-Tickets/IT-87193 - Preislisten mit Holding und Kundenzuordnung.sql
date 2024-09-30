WITH PrListStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'KUNDEN'
)
SELECT PrListKunde.KdNr AS [Preislisten-Nr.], PrListKunde.Name1 AS [Preislisten-Bezeichnung], PrListStatus.StatusBez AS [Preislisten-Status], PrListHolding.Holding AS [Preislisten-Holding], PrListHolding.Bez AS [Preislisten-Holding Bezeichnung], Kunden.KdNr, Kunden.SuchCode AS Kunde, Firma.Bez AS Firma, Holding.Holding, Holding.Bez AS [Holding-Bezeichnung], [Zone].ZonenCode AS Vertriebszone
FROM Kunden AS PrListKunde
JOIN Holding AS PrListHolding ON PrListKunde.HoldingID = PrListHolding.ID
JOIN PrListStatus ON PrListKunde.[Status] = PrListStatus.[Status]
LEFT JOIN KundPrLi ON KundPrLi.PrListKundenID = PrListKunde.ID
LEFT JOIN Kunden ON KundPrLi.KundenID = Kunden.ID
LEFT JOIN Firma ON Kunden.FirmaID = Firma.ID
LEFT JOIN Holding ON Kunden.HoldingID = Holding.ID
LEFT JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
WHERE PrListKunde.AdrArtID = 5
  AND (Kunden.[Status] = N'A' OR Kunden.[Status] IS NULL)