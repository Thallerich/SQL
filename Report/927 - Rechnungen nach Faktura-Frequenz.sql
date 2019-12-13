SELECT Firma.SuchCode AS Firma, Kunden.KdNr, Kunden.SuchCode AS Kunde, RechKo.RechNr, RechKo.RechDat, RechKo.NettoWert, RechKo.MwStBetrag, RechKo.BruttoWert
FROM RechKo
JOIN Firma ON RechKo.FirmaID = Firma.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
WHERE RechKo.FakFreqID IN ($2$)
  AND RechKo.RechDat BETWEEN $3$ AND $4$
  AND RechKo.FirmaID IN ($1$)
  AND RechKo.Status = N'F'
ORDER BY Firma, RechDat, RechNr;