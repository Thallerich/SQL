SELECT Firma.SuchCode AS FirmenNr, Firma.Bez AS Firma, Kunden.KdNr, Kunden.Debitor, Kunden.SuchCode AS Kunde, RechKo.Art, RechKo.RechNr, RechKo.RechDat AS Rechnungsdatum, RechKo.BruttoWert AS Brutto, RechKo.NettoWert AS Netto, RechKo.MwStBetrag AS MwSt, RechKo.SkontoBetrag AS Skonto, FibuExp.Zeitpunkt AS [FIBU-Übergabe], Kunden.BarRech AS [Barzahlung?]
FROM RechKo, Kunden, Firma, FibuExp
WHERE RechKo.KundenID = Kunden.ID
  AND Kunden.FirmaID = Firma.ID
  AND Firma.ID IN ($1$)
  AND RechKo.RechDat BETWEEN $2$ AND $3$
  AND RechKo.Art LIKE (
    CASE $4$
      WHEN 1 THEN N'_'
      WHEN 2 THEN N'R'
      WHEN 3 THEN N'G'
    END
  )
  AND RechKo.Status >= 'F'  -- mindestens gedruckt
  AND RechKo.Status < 'X'   -- nicht storniert oder ignoriert
  AND RechKo.FibuExpID = FibuExp.ID
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
ORDER BY Kunden.KdNr;