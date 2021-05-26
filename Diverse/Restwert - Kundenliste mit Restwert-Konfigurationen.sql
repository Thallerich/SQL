SELECT Firma.Bez AS Firma,
  KdGf.KurzBez AS Geschäftsbereich,
  [Zone].ZonenCode AS Vertriebsregion,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  IIF(BKRwConfig.ID < 0, NULL, BKRwConfig.RwConfigBez) AS [BK - Restwertkonfiguration],
  [BK - Berechnungs-Variante] =
    CASE IIF(BKRWConfig.ID < 0, -1, BKRwConfig.RWBerechnungsVar)
      WHEN 1 THEN N'Wochen'
      WHEN 2 THEN N'Wäschen'
      WHEN 3 THEN N'Wochen (bei max. Wäschen: RW = 0)'
      WHEN 4 THEN N'Wäschen (bei max. Wochen: RW = 0)'
      WHEN 5 THEN N'Konstant (bei max. Wochen: RW = 0)'
      WHEN 6 THEN N'Stufen'
      ELSE NULL
    END,
  IIF(BKRwConfig.ID <0, NULL, CAST(IIF(BKRwConfig.RueckVar = 0, 0, 1) AS bit)) AS [BK - Leasing weiter nach Abmeldung],
  BKRwConfPo.VkAufschlagProz AS [BK - Aufschlag %],
  BKRwConfPo.MinimumRwAbs AS [BK - Minimum],
  BKRwConfPo.MinimumRwProz AS [BK - Minimum %],
  BKRwConfPo.MindestRWAbs AS [BK - Mindestrestwert],
  BKRwConfPo.MindestRwProz AS [BK - Mindestrestwert %],
  BKRwConfPo.KonstantRwProz AS [BK - Konstanter Restwert %],
  BKRwConfPo.UseKdArtiVkPreis AS [BK - Verkaufspreis als Basis],
  IIF(FWRwConfig.ID < 0, NULL, FWRwconfig.RwConfigBez) AS [Pool - Restwertkonfiguration],
  [Pool - Berechnungs-Variante] =
    CASE IIF(FWRwConfig.ID < 0, -1, FWRwConfig.RWBerechnungsVar)
      WHEN 1 THEN N'Wochen'
      WHEN 2 THEN N'Wäschen'
      WHEN 3 THEN N'Wochen (bei max. Wäschen: RW = 0)'
      WHEN 4 THEN N'Wäschen (bei max. Wochen: RW = 0)'
      WHEN 5 THEN N'Konstant (bei max. Wochen: RW = 0)'
      WHEN 6 THEN N'Stufen'
      ELSE NULL
    END,
  IIF(FWRwConfig.ID < 0, NULL, CAST(IIF(FWRwConfig.RueckVar = 0, 0, 1) AS bit)) AS [Pool - Leasing weiter nach Abmeldung],
  FWRwConfPo.VkAufschlagProz AS [Pool - Aufschlag %],
  FWRwConfPo.MinimumRwAbs AS [Pool - Minimum],
  FWRwConfPo.MinimumRwProz AS [Pool - Minimum %],
  FWRwConfPo.MindestRWAbs AS [Pool - Mindestrestwert],
  FWRwConfPo.MindestRwProz AS [Pool - Mindestrestwert %],
  FWRwConfPo.KonstantRwProz AS [Pool - Konstanter Restwert %],
  FWRwConfPo.UseKdArtiVkPreis AS [Pool - Verkaufspreis als Basis]
FROM Kunden
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN RwConfig AS BKRwConfig ON Kunden.RWConfigID = BKRwConfig.ID
LEFT JOIN RwConfPo AS BKRwConfPo ON BKRwConfPo.RwConfigID = BKRwConfig.ID AND BKRwConfPo.RwArtID = 1
JOIN RwConfig AS FWRwConfig ON Kunden.RWPoolTeileConfigID = FWRwConfig.ID
LEFT JOIN RwConfPo AS FWRwConfPo ON FWRwConfPo.RwConfigID = FWRwConfig.ID AND FWRwConfPo.RwArtID = 1
WHERE Kunden.AdrArtID = 1
  AND Kunden.Status = N'A'
  AND KdGf.Status = N'A'
  AND Firma.Status = N'A'
  AND KdGf.KurzBez != N'INT'
ORDER BY Firma, Geschäftsbereich, Vertriebsregion, KdNr;