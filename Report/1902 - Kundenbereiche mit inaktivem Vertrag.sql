SELECT KdBer.ID AS KdBerID, Vertrag.ID AS VertragID, Kunden.KdNr, Kunden.SuchCode AS Kunde, Bereich.BereichBez$LAN$ AS Kundenbereich, Vertrag.Nr AS [Vertrag Nr.], Vertrag.Bez AS Vertragsbezeichung, Vertrag.Status
FROM KdBer
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN Kunden ON KdBer.KundenID = Kunden.ID
JOIN Vertrag ON KdBer.VertragID = Vertrag.ID
WHERE Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1
  AND KdBer.Status = N'A'
  AND ISNULL(Vertrag.Status, N'I') = N'I'
  AND Kunden.FirmaID = $1$
  AND Kunden.SichtbarID IN ($SICHTBARIDS$);