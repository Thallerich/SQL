SELECT Holding.Holding, Kunden.KdNr, Kunden.Suchcode AS Kunde, Bereich.BereichBez AS Produktbereich, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, SUM(RechPo.GPreis) AS Betrag
FROM Kunden
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN RechKo ON RechKo.KundenID = Kunden.ID
JOIN RechPo ON RechPo.RechKoID = RechKo.ID
JOIN Abteil ON RechPo.AbteilID = Abteil.ID
JOIN Bereich ON RechPo.BereichID = Bereich.ID
WHERE Holding.Holding IN (N'HOGAST', N'HGP')
  AND Firma.SuchCode = N'51'
  AND RechKo.RechDat BETWEEN N'2017-05-01' AND N'2018-04-30'
  AND RechKo.Status BETWEEN N'F' AND N'S'
GROUP BY Holding.Holding, Kunden.KdNr, Kunden.SuchCode, Bereich.BereichBez, Abteil.Abteilung, Abteil.Bez
ORDER BY Holding, KdNr, Kostenstelle;