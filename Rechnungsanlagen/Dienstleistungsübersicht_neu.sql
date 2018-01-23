SELECT RechPo.Bez AS Positionsbezeichnung, RechKo.RechNr, RechKo.Debitor, RechKo.EffektivBis, RechKo.RechDat, SUM(RechPo.GPreis) AS Positionssumme
FROM RechPo, RechKo
WHERE RechPo.RechKoID = RechKo.ID
  AND RechKo.ID = $RECHKOID$
GROUP BY RechPo.Bez, RechKo.RechNr, RechKo.Debitor, RechKo.EffektivBis, RechKo.RechDat;