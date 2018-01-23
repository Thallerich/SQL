SELECT 'Sender???' AS Sender, KdArti.Referenz AS COLArt, SUM(RechPo.GPreis) AS Betrag, LEFT(Abteil.Bez, 6) AS Empfänger, '' AS Auftrag, RechKo.RechNr, Kunden.KdNr
FROM RechKo, Kunden, RechPo, KdArti, Bereich, Abteil
WHERE RechPo.AbteilID = Abteil.ID
  AND RechPo.BereichID = Bereich.ID
  AND KdArti.ID = RechPo.KdArtiID
  AND RechPo.RechKoID = RechKo.ID
  AND Kunden.ID = RechKo.KundenID
  AND TRIM(CONVERT(char(4), YEAR(RechKo.RechDat))) + '-' + IIF(MONTH(RechKo.RechDat) < 10, '0', '') + TRIM(CONVERT(varchar(2), MONTH(RechKo.RechDat))) = $1$
  AND Kunden.ID IN ($2$)
GROUP BY KdArti.Referenz, LEFT(Abteil.Bez, 6), RechKo.RechNr, Kunden.KdNr
ORDER BY Kunden.KdNr, RechKo.RechNr, Empfänger ASC;