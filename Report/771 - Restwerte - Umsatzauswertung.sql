SELECT KdGf.KurzBez AS Geschäftsbereich, Firma.SuchCode AS Firma, [Zone].ZonenCode AS Vertriebszone,Holding.Holding ,Kunden.KdNr, Kunden.SuchCode AS Kunde, RechKo.RechNr, RechKo.RechDat AS Rechnungsdatum, RKoType.RKoTypeBez$LAN$ AS [Rechnungstyp], RPoType.RPoTypeBez$LAN$ AS [Positionstyp], IIF(RechKo.Art = 'G', GutschriftRwArt.RwArtBez$LAN$, RwArt.RwArtBez$LAN$) AS [Restwert-Art], SUM(RechPo.GPreis) AS [Umsatz netto]
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Firma ON RechKo.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN RKoType ON RechKo.RKoTypeID = RKoType.ID
JOIN RPoType ON RechPo.RPoTypeID = RPoType.ID
LEFT JOIN TeilSoFa ON TeilSoFa.RechPoID = RechPo.ID
LEFT JOIN RwArt ON TeilSoFa.RwArtID = RwArt.ID
LEFT JOIN TeilSoFa AS GutschriftTeilSoFa ON GutschriftTeilSoFa.RechPoGutschriftID = RechPo.ID
LEFT JOIN RwArt AS GutschriftRwArt ON GutschriftTeilSoFa.RwArtID = GutschriftRwArt.ID
WHERE Kunden.FirmaID IN ($1$)
  AND Kunden.KdGfID IN ($2$)
  AND Kunden.ZoneID IN ($3$)
  AND Kunden.HoldingID IN ($4$)
  AND RechKo.RKoTypeID IN ($5$)
  AND RechKo.RechDat BETWEEN $STARTDATE$ AND $ENDDATE$
  AND RPoType.StatistikGruppe = N'Restwerte'
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
GROUP BY KdGf.KurzBez, Firma.SuchCode, [Zone].ZonenCode,Holding.Holding, Kunden.KdNr, Kunden.SuchCode, RechKo.Rechnr, RechKo.RechDat, RKoType.RKoTypeBez$LAN$, RPoType.RPoTypeBez$LAN$, IIF(RechKo.Art = 'G', GutschriftRwArt.RwArtBez$LAN$, RwArt.RwArtBez$LAN$);