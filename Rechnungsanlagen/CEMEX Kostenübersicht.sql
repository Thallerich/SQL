SELECT RechKo.RechNr, RechKo.RechDat, MIN(Wochen.Woche) AS StartWoche, MAX(Wochen.Woche) AS EndWoche, Traeger.PersNr, SUM(TraeArch.Menge * AbtKdArW.EPreis) AS PosSumme
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN AbtKdArW ON AbtKdArW.RechPoID = RechPo.ID
JOIN TraeArch ON TraeArch.AbtKdArWID = AbtKdArW.ID
JOIN Wochen ON TraeArch.WochenID = Wochen.ID
JOIN TraeArti ON TraeArch.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
WHERE RechKo.ID = $RECHKOID$
GROUP BY RechKo.RechNr, RechKo.RechDat, Traeger.PersNr;