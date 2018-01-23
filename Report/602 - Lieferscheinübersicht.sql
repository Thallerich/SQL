SELECT LsKo.LsNr, LsKo.Datum, Kunden.KdNr, Kunden.SuchCode, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa
FROM Vsa, Kunden, LsKo
WHERE LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND LsKo.Datum BETWEEN $1$ AND $2$
  AND Kunden.ID = $ID$
  AND EXISTS (
    SELECT LsPo.*
    FROM LsPo
    WHERE LsPo.LsKoID = LsKo.ID
  )
GROUP BY LsKo.LsNr, LsKo.Datum, Kunden.KdNr, Kunden.SuchCode, Vsa.SuchCode, Vsa.Bez
ORDER BY Kunden.KdNr, VsaNr, LsKo.LsNr;