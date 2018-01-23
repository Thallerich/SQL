SELECT Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, RechKo.RechNr, RechKo.Art, RechKo.RechDat AS Rechnungsdatum, RechPo.Bez AS Positionsbezeichnung, RechPo.Menge, RechPo.EPreis AS Einzelpreis, RechPo.GPreis AS Positionssumme
FROM RechPo, RechKo, Kunden, Holding
WHERE RechPo.RechKoID = RechKo.ID
  AND RechKo.KundenID = Kunden.ID
  AND Kunden.HoldingID = Holding.ID
  AND Holding.ID IN ($1$)
  AND (
    ($2$ = 1 AND $3$ = 1)
    OR ($2$ = 1 AND $3$ = 0 AND RechKo.Art = 'R')
    OR ($2$ = 0 AND $3$ = 1 AND RechKo.Art = 'G')
  )
  AND RechKo.RechDat BETWEEN $4$ AND $5$
ORDER BY Holding.Holding, Kunden.KdNr, RechKo.RechDat;