SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, VertragWae.WaeBez$LAN$ + N' (' + VertragWae.Code + N')' AS Vertragswährung, RechWae.WaeBez$LAN$ + N' (' + RechWae.Code + N')' AS Rechnungswährung
FROM Kunden
JOIN Wae AS VertragWae ON Kunden.VertragWaeID = VertragWae.ID
JOIN Wae AS RechWae ON Kunden.RechWaeID = RechWae.ID
WHERE Kunden.FirmaID IN ($1$)
  AND Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1
  AND Kunden.SichtbarID IN ($SICHTBARIDS$);