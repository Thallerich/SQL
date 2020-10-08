SELECT Firma.SuchCode AS FirmenNr, Firma.Bez AS Firma, Kunden.KdNr, Kunden.Debitor, Kunden.SuchCode AS Kunde, Standort.Bez AS Kundenstandort, KdGf.KurzBez AS Geschäftsbereich, RKoType.RKoTypeBez$LAN$ AS Rechnungstyp, RechKo.Art, RechKo.RechNr, RechKo.RechDat AS Rechnungsdatum, RechKo.BruttoWert AS Brutto, RechKo.NettoWert AS Netto, RechKo.MwStBetrag AS MwSt, RechKo.SkontoBetrag AS Skonto, FibuExp.Zeitpunkt AS [FIBU-Übergabe], Kunden.BarRech AS [Barzahlung?]
FROM RechKo, Kunden, Firma, KdGf, FibuExp, Standort, RKoType
WHERE RechKo.KundenID = Kunden.ID
  AND Kunden.FirmaID = Firma.ID
  AND Kunden.KdGfID = KdGf.ID
  AND Kunden.StandortID = Standort.ID
  AND RechKo.RKoTypeID = RKoType.ID
  AND Firma.ID IN ($1$)
  AND ((RechKo.RechDat BETWEEN $2$ AND $3$ AND $5$ = 0) OR ((RechKo.RechDat IS NULL OR RechKo.RechDat BETWEEN $2$ AND $3$) AND $5$ = 1))
  AND RechKo.Art LIKE (
    CASE $4$
      WHEN 1 THEN N'_'
      WHEN 2 THEN N'R'
      WHEN 3 THEN N'G'
    END
  )
  AND ((RechKo.Status >= 'F' AND $5$ = 0) OR ($5$ = 1))
  AND RechKo.Status < 'X'   -- nicht storniert oder ignoriert
  AND RechKo.FibuExpID = FibuExp.ID
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
ORDER BY Kunden.KdNr;