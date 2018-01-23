SELECT '50' AS [Posting key], '62040707' AS [Account], SUM(RechPo.GPreis) AS [Betrag], '0V' AS [Tax Code], Abteil.Bez AS [Kostenstelle], '' AS [Auftrag], '' AS [PSP-Element], '' AS [Profitcenter], 'Mietwäsche ' + TRIM(IIF(MONTH(RechKo.RechDat) < 10, '0' + CONVERT(char(1), MONTH(RechKo.RechDat)), CONVERT(char(2), MONTH(RechKo.RechDat)))) + '/' + CONVERT(char(4), YEAR(RechKo.RechDat)) AS [Text], Abteil.Bez AS [Zuordnung], '' AS [Material], '' AS [Menge], '' AS [Basis-ME], '' AS [Werk], '' AS [Bewegungsart]
FROM RechPo, RechKo, Vsa, Abteil
WHERE RechPo.RechKoID = RechKo.ID
  AND RechPo.VsaID = Vsa.ID
  AND RechPo.AbteilID = Abteil.ID
  AND RechKo.ID = $RECHKOID$
GROUP BY Abteil.Bez, 'Mietwäsche ' + TRIM(IIF(MONTH(RechKo.RechDat) < 10, '0' + CONVERT(char(1), MONTH(RechKo.RechDat)), CONVERT(char(2), MONTH(RechKo.RechDat)))) + '/' + CONVERT(char(4), YEAR(RechKo.RechDat)), Abteil.Bez
ORDER BY [Kostenstelle], [Posting key];