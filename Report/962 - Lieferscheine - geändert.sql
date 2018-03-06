SELECT KdGf.KurzBez AS SGF, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nr.], Vsa.Bez AS VSA, LsKo.LsNr AS [Lieferschein-Nr.], LsKo.Datum AS [Lieferdatum], Mitarbei.Name AS [geändert von]
FROM LsKo
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Mitarbei ON LsKo.AenderMitarbeiID = Mitarbei.ID
WHERE KdGf.ID IN ($3$)
  AND LsKo.Datum BETWEEN $1$ AND $2$
  AND LsKo.AenderMitarbeiID > 0;