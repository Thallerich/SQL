SELECT RechKo.RechNr, RechKo.RechDat, RechKo.LeistDat, RechKo.Debitor, Kunden.KdNr, RechKo.Name1, RechKo.Name2, RechKo.BruttoWert, RechKo.NettoWert, RechKo.MwstBetrag, Status.StatusBez AS Status, FibuExp.Zeitpunkt AS Übergabedatum, FibuExp.Benutzer AS Übergabebenutzer, FibuExp.BisDatum AS ÜbergabeBis
FROM Kunden, Status, RechKo
LEFT JOIN FibuExp ON RechKo.FibuExpID = FibuExp.ID
WHERE RechKo.KundenID = Kunden.ID
  AND RechKo.Status = Status.Status
  AND Status.Tabelle = 'RECHKO'
  AND RechKo.RechDat BETWEEN $1$ AND $2$
  AND RechKo.Status <> 'X'
  AND CONVERT(char(10), RechKo.RechNr) LIKE '$3$%'
  AND RechKo.FibuExpID < IIF($4$ = $TRUE$, 0, 1000000)
ORDER BY RechKo.Status, RechKo.RechNr;