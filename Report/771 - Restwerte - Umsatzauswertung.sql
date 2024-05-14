SELECT KdGf.KurzBez AS Geschäftsbereich, Firma.SuchCode AS Firma, [Zone].ZonenCode AS Vertriebszone, Kunden.KdNr, Kunden.SuchCode AS Kunde, RechKo.RechNr, RechKo.RechDat AS Rechnungsdatum, RPoType.RPoTypeBez$LAN$ AS [Rechnungstyp], RwArt.RwArtBez$LAN$ AS [Restwert-Art], SUM(RechPo.GPreis) AS [Umsatz netto]
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN Firma ON RechKo.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN RPoType ON RechPo.RPoTypeID = RPoType.ID
LEFT JOIN TeilSoFa ON TeilSoFa.RechPoID = RechPo.ID
LEFT JOIN RwArt ON TeilSoFa.RwArtID = RwArt.ID
WHERE Kunden.FirmaID IN ($1$)
  AND Kunden.KdGfID IN ($2$)
  AND Kunden.ZoneID IN ($3$)
  AND RechKo.RechDat BETWEEN $STARTDATE$ AND $ENDDATE$
  AND RPoType.StatistikGruppe = N'Restwerte'
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
GROUP BY KdGf.KurzBez, Firma.SuchCode, [Zone].ZonenCode, Kunden.KdNr, Kunden.SuchCode, RechKo.Rechnr, RechKo.RechDat, RPoType.RPoTypeBez$LAN$, RwArt.RwArtBez$LAN$;