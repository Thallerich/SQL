SELECT RechKo.RechNr, RechKo.RechDat, RechKo.VonDatum, RechKo.BisDatum, RechKo.MasterWochenID, RechKo.ErsteWo, dbo.WeekOfDate(RechKo.VonDatum) AS LeasVonWeek, dbo.WeekOfDate(RechKo.BisDatum) AS LeasBisWeek, IIF(RechKo.BisDatum IS NULL, 0, 1) AS HatLeasing, Kunden.KdNr, KUnden.Name1 AS KdName1, Kunden.Name2 AS KdName2, Kunden.Name3 AS KdName3, Kunden.AdressBlock AS KdAdressBlock, Bereich.Bereich, Bereich.BereichBez$LAN$ AS BereichBez, SUM(RechPo.Menge) AS Menge, SUM(RechPo.GPreis) AS Betrag
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN FakFreq ON RechKo.FakFreqID = FakFreq.ID
JOIN Bereich ON RechPo.BereichID = Bereich.ID
WHERE RechKo.ID = $RECHKOID$
GROUP BY RechKo.RechNr, RechKo.RechDat, RechKo.VonDatum, RechKo.BisDatum, RechKo.MasterWochenID, RechKo.ErsteWo, dbo.WeekOfDate(RechKo.VonDatum), dbo.WeekOfDate(RechKo.BisDatum), IIF(RechKo.BisDatum IS NULL, 0, 1), Kunden.KdNr, KUnden.Name1, Kunden.Name2, Kunden.Name3, Kunden.AdressBlock, Bereich.Bereich, Bereich.BereichBez$LAN$
ORDER BY Bereich ASC;