SELECT RechKo.RechNr, RechKo.RechDat, WocheVon.Woche AS StartWoche, WocheBis.Woche AS EndWoche, Abteil.Abteilung AS KsSt, Abteil.Bez AS KsStBez, SUM(RechPo.GPreis) AS PosSumme
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Abteil ON RechPo.AbteilID = Abteil.ID
JOIN Week AS WocheVon ON RechKo.VonDatum BETWEEN WocheVon.VonDat AND WocheVon.BisDat
JOIN Week AS WocheBis ON RechKo.BisDatum BETWEEN WocheBis.VonDat AND WocheBis.BisDat
WHERE RechKo.ID = $RECHKOID$
GROUP BY RechKo.RechNr, RechKo.RechDat, WocheVon.Woche, WocheBis.Woche, Abteil.Abteilung, Abteil.Bez
ORDER BY KsSt ASC;