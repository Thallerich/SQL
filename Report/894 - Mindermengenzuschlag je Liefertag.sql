SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, KdGf.KurzBez AS Geschäftsbereich, [Zone].ZonenCode AS Vertriebszone, Holding.Holding, RechKo.RechNr AS Rechnungsnummer, RechKo.RechDat AS Rechnungsdatum, IIF(RechKo.Art = N'G', N'Gutschrift', N'Rechnung') AS Rechnungsart, RechPo.VonDatum AS Liefertag, RechPo.Bez AS Positionsbezeichnung, RechPo.GPreis AS Mindermengenzuschlag
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
WHERE RechPo.RPoTypeID = 29  -- nur Mindermengenzuschlag je Liefertag
  AND RechPo.VonDatum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Holding.ID IN ($2$)
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
ORDER BY KdNr ASC, Liefertag ASC;