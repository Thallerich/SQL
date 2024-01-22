WITH VertragProKunde AS (
  SELECT DISTINCT Vertrag.KundenID, Vertrag.VertragAbschluss
  FROM Vertrag
  WHERE Vertrag.[Status] = N'A'
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, VertragWae.WaeBez$LAN$ + N' (' + VertragWae.Code + N')' AS Vertragswährung, RechWae.WaeBez$LAN$ + N' (' + RechWae.Code + N')' AS Rechnungswährung, CAST(Kunden.Anlage_ AS date) AS [Anlagedatum Kunde], VertragProKunde.VertragAbschluss AS [Vertrag abgeschlossen am]
FROM Kunden
JOIN Wae AS VertragWae ON Kunden.VertragWaeID = VertragWae.ID
JOIN Wae AS RechWae ON Kunden.RechWaeID = RechWae.ID
LEFT JOIN VertragProKunde ON VertragProKunde.KundenID = Kunden.ID
WHERE Kunden.FirmaID IN ($1$)
  AND Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
  AND Kunden.Anlage_ > $2$;