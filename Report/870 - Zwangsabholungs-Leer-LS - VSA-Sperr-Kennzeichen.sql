SELECT DISTINCT Firma.SuchCode AS Firma, [Zone].ZonenCode AS Vertriebszone, KdGf.KurzBez AS Geschäftsbereich, Standort.SuchCode AS [Expeditions-Standort], Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.ID AS VsaID, Vsa.VsaNr, Vsa.Bez AS [VSA-Bezeichnung], Vsa.NichtImmerLS AS [keine Zwangsabholungs-Leer-LS]
FROM Vsa
JOIN VsaTour ON VsaTour.VsaID = Vsa.ID
JOIN Touren ON VsaTour.TourenID = Touren.ID
JOIN Standort ON Touren.ExpeditionID = Standort.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
WHERE CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
  AND Vsa.Status = N'A'
  AND Kunden.Status = N'A'
  AND Firma.ID IN ($1$)
  AND Standort.ID IN ($2$)
  AND Vsa.NichtImmerLS = $3$
ORDER BY Kunden.KdNr, Vsa.VsaNr;