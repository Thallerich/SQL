SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Holding.Bez AS Holding, Firma.Bez AS Firma, [Zone].ZonenBez$LAN$ AS Vertriebszone, KdGf.KurzBez AS Geschäftsbereich, Vertrag.Nr AS VertragNr, Vertrag.Bez AS Vertragsbezeichnung, VertTyp.VertTypBez$LAN$ AS Vertragstyp, Vertrag.VertragLfdNr AS [laufende Nummer], Bereich.BereichBez$LAN$ AS Produktbereich, Vertrag.VertragAbschluss, Vertrag.VertragStart, Vertrag.VertragEnde, Vertrag.VertragEndeMoegl AS [nächstmögliches Ende]
FROM Vertrag
JOIN VertTyp ON Vertrag.VertTypID = VertTyp.ID
JOIN Kunden ON Vertrag.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Bereich ON Vertrag.BereichID = Bereich.ID
WHERE Vertrag.[Status] = N'A'
  AND Firma.ID IN ($1$)
  AND KdGf.ID IN ($2$)
  AND [Zone].ID IN ($3$)
  AND Holding.ID IN ($4$);