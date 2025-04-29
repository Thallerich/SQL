SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde
FROM Kunden
WHERE Kunden.AdrArtID = 1
  AND Kunden.[Status] = N'A'
  AND Kunden.FirmaID = (SELECT Firma.ID FROM Firma WHERE Firma.SuchCode = N'SMRO')
  AND Kunden.KdGfID = (SELECT KdGf.ID FROM KdGf WHERE KdGf.KurzBez = N'JOB')
  AND NOT EXISTS (
    SELECT KdAusSta.*
    FROM KdAusSta
    WHERE KdAusSta.KundenID = Kunden.ID
  )