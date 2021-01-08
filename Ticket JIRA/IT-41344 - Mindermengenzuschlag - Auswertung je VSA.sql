SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nummer], Vsa.SuchCode AS [VSA-Stichwort], Vsa.Bez AS [VSA-Bezeichnung], Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS [Kostenstellen-Bezeichnung], LsKo.Datum AS Lieferdatum, SUM(LsPo.Menge * LsPo.EPreis) AS Lieferwert
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON LsPo.AbteilID = Abteil.ID
WHERE Kunden.KdNr = 260783
  AND LsKo.Datum BETWEEN N'2020-12-01' AND N'2020-12-31'
GROUP BY Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.SuchCode, Vsa.Bez, Abteil.Abteilung, Abteil.Bez, LsKo.Datum
ORDER BY KdNr, [VSA-Nummer], Lieferdatum;