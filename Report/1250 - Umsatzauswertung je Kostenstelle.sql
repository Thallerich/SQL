SELECT FORMAT($STARTDATE$, N'dd.MM.yyyy', N'de-AT') + N' - ' + FORMAT($ENDDATE$, N'dd.MM.yyyy', N'de-AT') AS Zeitraum, Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, SUM(RechPo.GPreis) AS [Umsatz netto], Wae.IsoCode AS Währung
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Abteil ON RechPo.AbteilID = Abteil.ID
JOIN Wae ON RechKo.RechWaeID = Wae.ID
WHERE Kunden.ID IN ($3$)
  AND RechKo.RechDat BETWEEN $STARTDATE$ AND $ENDDATE$
  AND RechKo.[Status] >= N'N'
  AND RechKo.[Status] < N'X'
GROUP BY Holding.Holding, Kunden.KdNr, Kunden.SuchCode, Abteil.Abteilung, Abteil.Bez, Wae.IsoCode
ORDER BY KdNr, Kostenstelle;