SELECT KdGf.KurzBez AS SGF, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nr.], Vsa.Bez AS VSA, LsKo.LsNr AS [Lieferschein-Nr.], LsKo.Datum AS [Lieferdatum], Mitarbei.Name AS [geändert von]
FROM LsKo
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Mitarbei ON LsKo.AenderMitarbeiID = Mitarbei.ID
WHERE KdGf.ID IN ($2$)
  AND LsKo.Datum = $1$
  AND LsKo.AenderMitarbeiID > 0;