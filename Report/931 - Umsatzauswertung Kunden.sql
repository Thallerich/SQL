SELECT Firma.SuchCode AS Firma, KdGf.KurzBez AS Geschäftsbereich, Standort.Bez AS Hauptstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, FORMAT(RechKo.RechDat, N'MM/yyyy', N'de-AT') AS Monat, SUM(IIF(RechPo.RPoTypeID IN (1, 2, 8, 9, 14, 15, 26, 35), RechPo.GPreis, 0)) AS Umsatz
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN Firma ON RechKo.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
WHERE RechKo.EffektivBis BETWEEN $2$ AND $3$
  AND RechKo.Status < N'X'
  AND Kunden.StandortID IN ($1$)
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
GROUP BY Firma.SuchCode, KdGf.KurzBez, Standort.Bez, Kunden.KdNr, Kunden.SuchCode, FORMAT(RechKo.RechDat, N'MM/yyyy', N'de-AT');