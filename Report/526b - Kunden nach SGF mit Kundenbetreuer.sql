WITH Kundenstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'KUNDEN')
)
SELECT DISTINCT KdGf.KurzBez AS Geschäftsbereich, Firma.Bez AS Firma, Kundenstatus.StatusBez AS Kundenstatus, ABC.ABCBez$LAN$ AS Kundenklasse, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kunden.Name1 AS Adresszeile1, Kunden.Name2 AS Adresszeile2, Kunden.Name3 AS Adresszeile3, Kunden.Strasse, Kunden.Land, Kunden.PLZ, Kunden.Ort, Kunden.KundeSeit AS [Kunde seit], ZahlZiel.ZahlZielBez$LAN$ AS Zahlungsziel, Mitarbei.Name, Mitarbei.Initialen AS Kundenbetreuer
FROM Kunden
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Kundenstatus ON Kunden.Status = Kundenstatus.Status
JOIN ABC ON Kunden.ABCID = ABC.ID
JOIN KdBer ON KdBer.KundenID = Kunden.ID
JOIN Mitarbei ON KdBer.BetreuerID = Mitarbei.ID
JOIN ZahlZiel ON Kunden.ZahlZielID = ZahlZiel.ID
WHERE Kunden.AdrArtID = 1
  AND Kundenstatus.ID IN ($2$)
  AND KdGf.ID IN ($1$)
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
ORDER BY Kunden.KdNr;