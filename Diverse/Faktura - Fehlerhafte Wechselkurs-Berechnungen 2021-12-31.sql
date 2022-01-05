DROP TABLE IF EXISTS #TmpRKoCheck;
GO

SELECT Firma.SuchCode AS Firma, Kunden.KdNr, Kunden.SuchCode AS Kunde, RechKo.RechNr, RechKo.RechDat, VertWae.Code AS Vertragswährung, RechWae.Code AS Rechnungswährung, WaeKurs.Kursdatum, WaeKurs.Wechselkurs, RechKo.NettoWertVertWae, SUM(RechPo.GPreisVertWae) AS NettoWertCalcVertWae, SUM(RechPo.GPreisVertWae * RechPo.RabattProz / 100) AS NettoRabattVertWae, SUM(RechPo.Rabatt) AS Rabatt, RechKo.NettoWert [Nettobetrag falsch], RechKo.WaeKursID, VertWae.RoundFinalNetto, RechWae.RoundFinal
INTO #TmpRKoCheck
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN WAE AS VertWae ON RechKo.VertragWaeID = VertWae.ID
JOIN Wae AS RechWae ON RechKo.RechWaeID = RechWae.ID
JOIN WaeKurs ON RechKo.WaeKursID = WaeKurs.ID
JOIN Firma ON RechKo.FirmaID = Firma.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
WHERE Firma.SuchCode IN (N'SMKR', N'SMRO')
  AND RechKo.RechDat >= N'2021-12-31'
  AND RechKo.Status BETWEEN N'F' AND N'X'
GROUP BY Firma.SuchCode, Kunden.KdNr, Kunden.SuchCode, RechKo.RechNr, RechKo.RechDat, VertWae.Code, RechWae.Code, WaeKurs.Kursdatum, WaeKurs.Wechselkurs, RechKo.NettoWertVertWae, RechKo.NettoWert, RechKo.WaeKursID, VertWae.RoundFinalNetto, RechWae.RoundFinal
ORDER BY Firma, KdNr, RechNr;

GO

SELECT RKoCheck.Firma, RKoCheck.KdNr, RKoCheck.Kunde, RKoCheck.RechNr, RKoCheck.RechDat, RKoCheck.Vertragswährung, RKoCheck.Rechnungswährung, RKoCheck.Kursdatum, RKoCheck.Wechselkurs, /* RKoCheck.NettoWertVertWae AS [NettoLtRKo], RKoCheck.Rabatt, */ dbo.AdvRoundExact(RKoCheck.NettoWertCalcVertWae - RKoCheck.NettoRabattVertWae, RKoCheck.RoundFinalNetto) AS [Nettobetrag Vertagswährung], RKoCheck.[Nettobetrag falsch], dbo.advRoundExact(convnetto.NachPreis, RKoCheck.RoundFinalNetto) AS [Nettobetrag korrekt], dbo.AdvRoundExact(convnetto.NachPreis - RKoCheck.[Nettobetrag falsch], RKoCheck.RoundFinal) AS Differenz
FROM #TmpRKoCheck AS RKoCheck
CROSS APPLY advFunc_ConvertExchangeRateWithWaeKursID(RKoCheck.WaeKursID, RKoCheck.NettoWertCalcVertWae - RKoCheck.NettoRabattVertWae) AS convnetto
WHERE dbo.AdvRoundExact(convnetto.NachPreis, RKoCheck.RoundFinalNetto) - RKoCheck.[Nettobetrag falsch] != 0;

GO