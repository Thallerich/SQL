SELECT KdGf.KurzBez AS Geschäftsbereich, Firma.SuchCode AS Firma, Kunden.KdNr, Kunden.SuchCode AS Kunde, RechKo.RechNr, RechKo.RechDat AS Rechnungsdatum, RPoType.RPoTypeBez$LAN$ AS [Rechnungstyp], SUM(RechPo.GPreis) AS [Umsatz netto]
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN Firma ON RechKo.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN RPoType ON RechPo.RPoTypeID = RPoType.ID
WHERE Firma.ID IN ($1$)
  AND RechKo.RechDat BETWEEN $STARTDATE$ AND $ENDDATE$
  AND KdGf.ID IN ($2$)
  AND RPoType.StatistikGruppe = N'Restwerte'
GROUP BY KdGf.KurzBez, Firma.SuchCode, Kunden.KdNr, Kunden.SuchCode, RechKo.Rechnr, RechKo.RechDat, RPoType.RPoTypeBez$LAN$
ORDER BY Firma, KdNr, Rechnungsdatum;