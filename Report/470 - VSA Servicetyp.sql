SELECT KdGF.KdGfBez AS Geschäftsbereich, Kunden.KdNr, Kunden.SuchCode AS Kunde, VSA.SuchCode AS VSANr, Vsa.Status, VSA.Bez AS Vsa, ServType.ServTypeBez AS Serviceart
FROM Vsa, Kunden, KdGF, ServType
WHERE Vsa.ServTypeID IN ($2$) 
  AND Kunden.ID = VSA.KundenID 
  AND Kunden.KdGFID = KdGF.ID 
  AND KdGF.ID IN ($1$)
  AND Vsa.ServTypeID = ServType.ID
ORDER BY Geschäftsbereich, KdNr, VsaNr;