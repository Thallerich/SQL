SELECT RechPo.Bez AS Positionsbezeichnung, RechKo.RechNr, RechKo.Debitor, RechKo.EffektivBis, RechKo.RechDat, RechPo.AbteilID, Abteil.Abteilung AS KsSt, Abteil.Bez AS KsStBez, SUM(RechPo.GPreis) AS Positionssumme
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Abteil ON RechPo.AbteilID = Abteil.ID
WHERE RechKo.ID = $RECHKOID$
GROUP BY RechPo.Bez, RechKo.RechNr, RechKo.Debitor, RechKo.EffektivBis, RechKo.RechDat, RechPo.AbteilID, Abteil.Abteilung, Abteil.Bez
ORDER BY KsSt;