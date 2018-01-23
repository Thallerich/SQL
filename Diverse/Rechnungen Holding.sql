SELECT Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, RechKo.RechNr, RechKo.Art, RechKo.RechDat AS Rechnungsdatum, RechPo.Bez AS Positionsbezeichnung, RechPo.Menge, RechPo.EPreis AS Einzelpreis, RechPo.GPreis AS Positionssumme
FROM RechPo, RechKo, Kunden, Holding
WHERE RechPo.RechKoID = RechKo.ID
  AND RechKo.KundenID = Kunden.ID
  AND Kunden.HoldingID = Holding.ID
  AND Holding.ID IN ($1$)
  AND IIF($2$ = TRUE AND $3$ = TRUE, 1 = 1, IIF($2$ = TRUE, RechKo.Art = 'R', IIF($3$ = TRUE, RechKo.Art = 'G', 1 = 0)))
  AND RechKo.RechDat BETWEEN $4$ AND $5$
ORDER BY Holding.Holding, Kunden.KdNr, RechKo.RechDat;