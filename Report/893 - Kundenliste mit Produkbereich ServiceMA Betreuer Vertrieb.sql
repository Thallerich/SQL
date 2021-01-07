WITH Kundenstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'KUNDEN')
)
SELECT Firma.Bez AS Firma,
  KdGf.Kurzbez AS Geschäftsbereich,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Kunden.Name1,
  Kunden.Name2,
  Kunden.Name3,
  Kunden.Strasse,
  Kunden.Land,
  Kunden.PLZ,
  Kunden.Ort,
  Kundenstatus.StatusBez AS Kundenstatus,
  Standort.Bez AS Hauptstandort,
  Kunden.UStIdNr,
  Bereich.BereichBez$LAN$ AS Produktbereich,
  ISNULL(ServiceKdBer.Nachname + N', ', N'') + ISNULL(ServiceKdBer.Vorname, N'') AS [Kundenservice],
  ISNULL(BetreuerKdBer.Nachname + N', ', N'') + ISNULL(BetreuerKdBer.Vorname, N'') AS [Kundenbetreuer],
  ISNULL(VertriebKdBer.Nachname + N', ', N'') + ISNULL(VertriebKdBer.Vorname, N'') AS [Vertrieb]
FROM Kunden
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
JOIN KdBer oN KdBer.KundenID = Kunden.ID
JOIN Mitarbei AS BetreuerKdBer ON KdBer.BetreuerID = BetreuerKdBer.ID
JOIN Mitarbei AS VertriebKdBer ON KdBer.VertreterID = VertriebKdBer.ID
JOIN Mitarbei AS ServiceKdBer ON KdBer.ServiceID = ServiceKdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN Kundenstatus ON Kundenstatus.Status = Kunden.Status
JOIN Standort ON Kunden.StandortID = Standort.ID
WHERE Kundenstatus.ID IN ($3$)
  AND Kunden.AdrArtID = 1
  AND Firma.ID IN ($1$)
  AND KdGf.ID IN ($2$);