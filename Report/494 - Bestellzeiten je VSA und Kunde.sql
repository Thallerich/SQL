SELECT KdGf.KurzBez AS Geschäftsbereich, Firma.Bez AS Firma, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS [Vsa-Stichwort], Vsa.Bez AS [Vsa-Bezeichnung], ServType.ServTypeBez$LAN$ AS Serviceart, CAST(AnfKo.Anlage_ AS date) AS Bestelldatum, FORMAT(AnfKo.Anlage_, N'HH:mm', N'de-AT') AS Bestellzeit, AnfKo.LieferDatum, AnfKo.AuftragsNr AS PackzettelNr
FROM AnfKo
JOIN Vsa ON AnfKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
JOIN ServType ON Vsa.ServTypeID = ServType.ID
WHERE KdGf.ID IN ($3$)
  AND Firma.ID IN ($2$)
  AND ServType.ID IN ($4$)
  AND AnfKo.Lieferdatum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Vsa.SichtbarID IN ($SICHTBARIDS$)
ORDER BY Lieferdatum, KdNr, VsaNr;