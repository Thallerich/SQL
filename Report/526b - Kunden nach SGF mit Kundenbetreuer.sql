WITH Kundenstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'KUNDEN')
)
SELECT DISTINCT KdGf.KurzBez AS Geschäftsbereich, Firma.Bez AS Firma, Kundenstatus.StatusBez AS Kundenstatus, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kunden.Name1 AS Adresszeile1, Kunden.Name2 AS Adresszeile2, Kunden.Name3 AS Adresszeile3, Kunden.Strasse, Kunden.Land, Kunden.PLZ, Kunden.Ort, Mitarbei.Name, Mitarbei.Initialen
FROM Kunden
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Kundenstatus ON Kunden.Status = Kundenstatus.Status
JOIN KdBer ON KdBer.KundenID = Kunden.ID
JOIN Mitarbei ON KdBer.BetreuerID = Mitarbei.ID
WHERE Kunden.AdrArtID = 1
  AND Kundenstatus.ID IN ($2$)
  AND KdGf.ID IN ($1$)
ORDER BY Kunden.KdNr;