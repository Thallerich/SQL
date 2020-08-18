SELECT RechKo.RechDat AS Rechnungsdatum, Kunden.KdNr AS Kundennummer, Kunden.SuchCode AS Kundenname, RechKo.RechNr AS Rechnungsnummer, SUM(RechPo.GPreis) AS Nettosumme, Vsa.Name2 AS Bezeichnung, Abteil.Bez AS Kostenstelle, CAST(Abteil.RechnungsMemo AS nchar) AS [Kostenstelle Auftrags-Nr.]
FROM RechPo, RechKo, Kunden, Holding, Abteil, Vsa
WHERE RechPo.RechKoID = RechKo.ID
  AND RechKo.KundenID = Kunden.ID
  AND Kunden.HoldingID = Holding.ID
  AND RechPo.AbteilID = Abteil.ID
  AND RechPo.VsaID = Vsa.ID
  AND Holding.ID IN ($1$)
  AND (
    ($2$ = 1 AND $3$ = 1)
    OR ($2$ = 1 AND $3$ = 0 AND RechKo.Art = 'R')
    OR ($2$ = 0 AND $3$ = 1 AND RechKo.Art = 'G')
  )
  AND RechKo.RechDat BETWEEN $STARTDATE$ AND $ENDDATE$
GROUP BY RechKo.RechDat, Kunden.KdNr, Kunden.SuchCode, RechKo.RechNr, Vsa.Name2, Abteil.Bez, CAST(Abteil.RechnungsMemo AS nchar)
ORDER BY RechKo.RechNr;