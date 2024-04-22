SELECT KdGF.KdGfBez$LAN$ AS Geschäftsbereich, Kunden.KdNr, Kunden.SuchCode AS Kunde, RechKo.RechNr, RechKo.RechDat, RechKo.Status
FROM RechKo, Kunden, KdGF
WHERE RechKo.Status = N'B'
  AND RechKo.KundenID = Kunden.ID
  AND Kunden.KdGFID = KdGF.ID
  AND KdGf.ID IN ($1$);