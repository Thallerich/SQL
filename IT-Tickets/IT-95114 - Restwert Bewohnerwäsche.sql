WITH Kundenstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'KUNDEN'
)
SELECT Firma.Bez AS Firma, [Zone].ZonenCode AS Vertriebszone, Standort.Bez AS Hauptstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kundenstatus.StatusBez AS [Status Kunde], Bereich.BereichBez AS Kundenbereich
FROM KdBer
JOIN Kunden ON KdBer.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN Kundenstatus ON Kunden.[Status] = Kundenstatus.[Status]
JOIN Bereich ON KdBer.BereichID = Bereich.ID
WHERE KdBer.RWBerechnungAlleTeile = 1