SELECT LsKo.LsNr, Vsa.VsaNr, VpsKo.ID AS VpsKoID, EinzTeil.Code, LsKo.Datum, CAST(Kunden.KdNr AS nvarchar) + N'_' + CAST(Vsa.VsaNr AS nvarchar) AS _SPLIT_
FROM EinzTeil
JOIN Scans ON Scans.EinzTeilID = EinzTeil.ID
JOIN VpsPo ON VpsPo.ID = Scans.VpsPoID
JOIN VpsKo ON VpsKo.id = VpsPo.VpsKoID
JOIN LsPo ON LsPo.ID = Scans.LsPoID
JOIN LsKo ON LsKo.id = LsPo.LsKoID
JOIN Vsa ON Vsa.id = LsKo.VsaID
JOIN Kunden ON Kunden.ID = Vsa.KundenID
WHERE Kunden.KdNr = 10006208
  AND Vsa.VsaNr IN (2, 3)
  AND LsKo.Status >= N'O'
  AND LsKo.DruckZeitpunkt >= DATEADD(hour, -1, GETDATE())
ORDER BY LsKo.LsNr;