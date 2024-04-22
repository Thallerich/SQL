SELECT Firma.SuchCode AS Firma, Kunden.KdNr, Kunden.SuchCode AS Kunde, RechKo.RechNr, RechKo.RechDat, RechKo.NettoWert, RechKo.MwStBetrag, RechKo.BruttoWert, ZahlZiel.ZahlZiel, ZahlZiel.ZahlZielBez$LAN$ AS Zahlungsziel
FROM RechKo
JOIN Firma ON RechKo.FirmaID = Firma.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN ZahlZiel ON RechKo.ZahlZielID = ZahlZiel.ID
WHERE RechKo.FakFreqID IN ($2$)
  AND RechKo.RechDat BETWEEN $3$ AND $4$
  AND RechKo.FirmaID IN ($1$)
  AND RechKo.ZahlZielID IN ($5$)
  AND RechKo.Status >= N'N'
  AND RechKo.Status < N'X';