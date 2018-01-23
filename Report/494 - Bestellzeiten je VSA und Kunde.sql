SELECT KdGf.KurzBez AS SGF, Firma.Bez AS Firma, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, CONVERT(date, AnfKo.Anlage_) AS Bestelldatum, IIF(DATEPART(hour, AnfKo.Anlage_) < 10, '0' + CONVERT(char(1), DATEPART(hour, AnfKo.Anlage_)), CONVERT(char(2), DATEPART(hour, AnfKo.Anlage_))) + ':' + IIF(DATEPART(minute, AnfKo.Anlage_) < 10, '0' + CONVERT(char(1), DATEPART(minute, AnfKo.Anlage_)), CONVERT(char(2), DATEPART(minute, AnfKo.Anlage_))) AS Bestellzeit, AnfKo.Lieferdatum
FROM AnfKo, Vsa, Kunden, KdGf, Firma
WHERE AnfKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.KdGfID = KdGf.ID
  AND Kunden.FirmaID = Firma.ID
  AND KdGf.ID IN ($1$)
  AND AnfKo.Lieferdatum BETWEEN  $2$ AND $3$
ORDER BY Lieferdatum, SGF, Firma, Kunden.KdNr, VsaNr;