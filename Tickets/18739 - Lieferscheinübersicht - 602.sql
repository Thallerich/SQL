SELECT LsKo.LsNr, LsKo.Datum, Kunden.KdNr, Kunden.SuchCode, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa
FROM Vsa, Kunden, LsKo
LEFT OUTER JOIN LsPo ON LsPo.LsKoID = LsKo.ID
WHERE LsKo.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND LsPo.ID IS NOT NULL
	AND LsKo.Datum BETWEEN $1$ AND $2$
	AND Kunden.ID = $ID$
GROUP BY LsKo.LsNr, LsKo.Datum, Kunden.KdNr, Kunden.SuchCode, VsaNr, Vsa
ORDER BY Kunden.KdNr, VsaNr, LsKo.LsNr;