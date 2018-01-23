SELECT '40' AS [Posting key], '62040707' AS [Account], RechPo.GPreis AS [Betrag], '0V' AS [Tax Code], Abteil.Bez AS [Kostenstelle], '' AS [Auftrag], '' AS [PSP-Element], '' AS [Profitcenter], RechPo.Bez AS [Text], 'VSA ' + Vsa.SuchCode AS [Zuordnung], '' AS [Material], '' AS [Menge], '' AS [Basis-ME], '' AS [Werk], '' AS [Bewegungsart]
FROM RechPo, RechKo, Vsa, Abteil
WHERE RechPo.RechKoID = RechKo.ID
  AND RechPo.VsaID = Vsa.ID
  AND RechPo.AbteilID = Abteil.ID
  AND RechKo.ID = $RECHKOID$
  
UNION
  
SELECT '50' AS [Posting key], '62040707' AS [Account], SUM(RechPo.GPreis) AS [Betrag], '' AS [Tax Code], '' AS [Kostenstelle], '' AS [Auftrag], '' AS [PSP-Element], '' AS [Profitcenter], '' AS [Text], '' AS [Zuordnung], '' AS [Material], '' AS [Menge], '' AS [Basis-ME], '' AS [Werk], '' AS [Bewegungsart]
FROM RechPo, RechKo, Vsa, Abteil
WHERE RechPo.RechKoID = RechKo.ID
  AND RechPo.VsaID = Vsa.ID
  AND RechPo.AbteilID = Abteil.ID
  AND RechKo.ID = $RECHKOID$;