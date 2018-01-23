SELECT Kunden.KdNr, Kunden.Name1, Vsa.VsaNr, Vsa.Name1, MIN(ScanFach.Fach) AS MinFach, MAX(ScanFach.Fach) AS MaxFach
FROM ScanFach, Traeger, Vsa, Kunden
WHERE ScanFach.TraegerID = Traeger.ID
  AND Traeger.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND ScanFach.ZielNrID = 111117
GROUP BY Kunden.KdNr, Kunden.Name1, Vsa.VsaNr, Vsa.Name1
ORDER BY MIN(ScanFach.Fach), MAX(ScanFach.Fach);