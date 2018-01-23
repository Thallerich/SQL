SELECT KdGf.KurzBez AS SGF, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.ID AS VsaID, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, LsKo.LsNr, LsKo.Datum
FROM LsKo, Vsa, Kunden, KdGf
WHERE LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.KdGfID = KdGf.ID
  AND LsKo.Datum BETWEEN $1$ AND $2$
  AND LsKo.Status >= 'Q'
  AND EXISTS (
    SELECT LsPo.*
    FROM LsPo
    WHERE LsPo.LsKoID = LsKo.ID
      AND LsPo.Menge > 0
  )
  AND NOT EXISTS (
    SELECT AnfKo.*
    FROM AnfKo
    WHERE AnfKo.LsKoID = LsKo.ID
  )
  AND EXISTS (
    SELECT VsaAnf.*
    FROM VsaAnf
    WHERE VsaAnf.VsaID = Vsa.ID
  )
  AND KdGf.ID IN ($3$);