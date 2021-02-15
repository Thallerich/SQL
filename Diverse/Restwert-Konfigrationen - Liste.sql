SELECT RwConfig.RwConfigBez AS Restwertkonfiguration,
  Berechnungsvariante = CASE RwConfig.RWBerechnungsVar
    WHEN 1 THEN N'Wochen'
    WHEN 2 THEN N'Wäschen'
    WHEN 3 THEN N'Wochen (bei Max-Wäschen -> Restwert = 0'
    WHEN 4 THEN N'Wäschen (bei Max-Wochen -> Restwert = 0'
    WHEN 5 THEN N'Konstant (bei Max-Wochen -> Restwert = 0'
    WHEN 6 THEN N'Stufen'
    ELSE N'???'
  END,
  RwConfig.MinRWEri AS [Minimum RW-Erinnerung],
  RwConfig.RWFakIVSA AS [Restwertfakturierung für inaktive VSAs],
  IIF(RwConfig.RueckVar = 0, N'sofort aus Leasing und RW festlegen', N'weiter im Leasing bis Eingang in Wäscherei') AS [Verhalten bei Abmeldung],
  IIF(RwConfig.RueckVarTausch = 0, N'sofort aus Leasing und RW festlegen', N'weiter im Leasing bis Eingang in Wäscherei') AS [Verhalten bei Austausch],
  RwArt.RwArtBez AS [Restwert-Art],
  CAST(RwConfPo.VkAufschlagProz AS float) / 100 AS [% Verkaufsaufschlag auf EK],
  RwConfPo.GroeZuschBasisRW AS [Größenzuschlag auf Basis-Restwerte im Kundenartikel aufrechnen],
  RwConfPo.MinimumRwAbs AS [Minimum-Restwert absolut],
  CAST(RwConfPo.MinimumRwProz AS float) / 100 AS [Minimum-Restwert prozentual],
  RwConfPo.MindestRWAbs AS [Mindestrestwert absolut],
  CAST(RwConfPo.MindestRwProz AS float) / 100 AS [Mindestrestwert prozentual],
  CAST(RwConfPo.KonstantRwProz AS float) / 100 AS [Konstanter Restwert - x% Basis-Restwert],
  [Kalkulation Basis-Restwert] = CASE
    WHEN RwConfPo.EKGrundAkt = 1 AND RwConfPo.EKGrundHist = 0 AND RwConfPo.EKZuschlAkt = 0 AND RwConfPo.EKZuschlHist = 0 AND RwConfPo.EKNsEmbAkt = 0 THEN N'Artikel-EK-Preis aktuell'
    WHEN RwConfPo.EKGrundAkt = 0 AND RwConfPo.EKGrundHist = 1 AND RwConfPo.EKZuschlAkt = 0 AND RwConfPo.EKZuschlHist = 0 AND RwConfPo.EKNsEmbAkt = 0 THEN N'Artikel-EK-Preis historisch'
    WHEN RwConfPo.EKGrundAkt = 1 AND RwConfPo.EKGrundHist = 0 AND RwConfPo.EKZuschlAkt = 1 AND RwConfPo.EKZuschlHist = 0 AND RwConfPo.EKNsEmbAkt = 0 THEN N'Artikel-EK-Preis aktuell + Größenzuschlag aktuell'
    WHEN RwConfPo.EKGrundAkt = 1 AND RwConfPo.EKGrundHist = 0 AND RwConfPo.EKZuschlAkt = 0 AND RwConfPo.EKZuschlHist = 1 AND RwConfPo.EKNsEmbAkt = 0 THEN N'Artikel-EK-Preis aktuell + Größenzuschlag historisch'
    WHEN RwConfPo.EKGrundAkt = 0 AND RwConfPo.EKGrundHist = 1 AND RwConfPo.EKZuschlAkt = 1 AND RwConfPo.EKZuschlHist = 0 AND RwConfPo.EKNsEmbAkt = 0 THEN N'Artikel-EK-Preis historisch + Größenzuschlag aktuell'
    WHEN RwConfPo.EKGrundAkt = 0 AND RwConfPo.EKGrundHist = 1 AND RwConfPo.EKZuschlAkt = 0 AND RwConfPo.EKZuschlHist = 1 AND RwConfPo.EKNsEmbAkt = 0 THEN N'Artikel-EK-Preis historisch + Größenzuschlag historisch'
    WHEN RwConfPo.EKGrundAkt = 1 AND RwConfPo.EKGrundHist = 0 AND RwConfPo.EKZuschlAkt = 0 AND RwConfPo.EKZuschlHist = 0 AND RwConfPo.EKNsEmbAkt = 1 THEN N'Artikel-EK-Preis aktuell + NS/Embleme'
    WHEN RwConfPo.EKGrundAkt = 0 AND RwConfPo.EKGrundHist = 1 AND RwConfPo.EKZuschlAkt = 0 AND RwConfPo.EKZuschlHist = 0 AND RwConfPo.EKNsEmbAkt = 1 THEN N'Artikel-EK-Preis historisch + NS/Embleme'
    WHEN RwConfPo.EKGrundAkt = 1 AND RwConfPo.EKGrundHist = 0 AND RwConfPo.EKZuschlAkt = 1 AND RwConfPo.EKZuschlHist = 0 AND RwConfPo.EKNsEmbAkt = 1 THEN N'Artikel-EK-Preis aktuell + Größenzuschlag aktuell + NS/Embleme'
    WHEN RwConfPo.EKGrundAkt = 1 AND RwConfPo.EKGrundHist = 0 AND RwConfPo.EKZuschlAkt = 0 AND RwConfPo.EKZuschlHist = 1 AND RwConfPo.EKNsEmbAkt = 1 THEN N'Artikel-EK-Preis aktuell + Größenzuschlag historisch + NS/Embleme'
    WHEN RwConfPo.EKGrundAkt = 0 AND RwConfPo.EKGrundHist = 1 AND RwConfPo.EKZuschlAkt = 1 AND RwConfPo.EKZuschlHist = 0 AND RwConfPo.EKNsEmbAkt = 1 THEN N'Artikel-EK-Preis historisch + Größenzuschlag aktuell + NS/Embleme'
    WHEN RwConfPo.EKGrundAkt = 0 AND RwConfPo.EKGrundHist = 1 AND RwConfPo.EKZuschlAkt = 0 AND RwConfPo.EKZuschlHist = 1 AND RwConfPo.EKNsEmbAkt = 1 THEN N'Artikel-EK-Preis historisch + Größenzuschlag historisch + NS/Embleme'
    ELSE N'???'
  END,
  RwConfPo.UseKdArtiVkPreis AS [Kundenartikel-VK-Preis als Basisrestwert],
  IIF(RwConfPo.IncludeWarehTime = 0, N'Teil nur während aktiv abschreiben', N'Teil auch im Lager abschreiben') AS [Teil wann abschreiben],
  RwConfPo.RPoBezTemplate AS [Text Rechnungsposition],
  RwConfPo.RPoMemoTemplate AS [Rechnungspositions-Zusatztext]
FROM RwConfig
JOIN RwConfPo ON RwConfPo.RwConfigID = RwConfig.ID
JOIN RwArt ON RwConfPo.RwArtID = RwArt.ID
WHERE RwConfig.ID > 0
  AND RwConfig.RwConfigBez NOT LIKE N'UHF Pool - %'
ORDER BY Restwertkonfiguration, [Restwert-Art];