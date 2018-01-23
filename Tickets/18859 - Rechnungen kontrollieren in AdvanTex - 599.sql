SELECT Kunden.KdNr, Kunden.SuchCode, KdGf.KurzBez AS GF, RKo.RechNr, RKo.Art, RKo.NettoWert
FROM RKo, Kunden, KdGf
WHERE RKo.KundenID = Kunden.ID
    AND Kunden.KdGfID = KdGf.ID
	AND Kunden.KdGfID IN ($1$)
	AND RKo.RechNr < 0
	AND RKo.Status NOT IN ('X', 'Y')
ORDER BY GF, Kunden.KdNr, RKo.RechNr;