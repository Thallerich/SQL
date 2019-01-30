WITH HadBestand AS (
  SELECT DISTINCT LagerBew.BestandID, CAST(1 AS bit) AS Bestand12Monate
  FROM LagerBew
  WHERE LagerBew.Differenz <> 0
    AND DATEDIFF(month, LagerBew.Zeitpunkt, GETDATE()) <= 12
),
HadKundenbestand AS (
  SELECT DISTINCT Teile.ArtGroeID, LagerArt.LagerID, CAST(1 AS bit) AS Kunde12Monate
  FROM Teile
  JOIN LagerArt ON Teile.LagerArtID = LagerArt.ID
  WHERE DATEDIFF(month, Teile.AusdienstDat, GETDATE()) <= 12
)
SELECT Artikel.ArtikelNr,
  Artikel.ArtikelBez AS Artikelbezeichnung,
  Artikel.SuchCode2 AS [Artikelbezeichnung 2],
  Artikel.ArtikelNr2 AS [ArtikelNr 2],
  Farbe.FarbeBez AS Farbe,
  Farbe2.FarbeBez AS [Farbe 2],
  ArtMust.ArtMustBez AS Muster,
  ArtKoll.ArtKollBez AS Kollektion,
  ArtMisch.ArtMischBez AS Gewebe,
  Bereich.BereichBez AS Bereich,
  ArtGru.ArtGruBez AS Artikelgruppe,
  ProdGru.ProdGruBez AS Sortiment,
  WaschPrg.Bez AS Waschprogramm,
  LiefArt.LiefArtBez AS Auslieferung,
  Abc.ABC AS [ABC-Klasse],
  Artikel.StueckGewicht AS [Stückgewicht (kg/Stück)],
  ProdHier.ProdHierBez AS Produkthierarchie,
  IIF(LiefGroe.ID < 0 OR LiefGroe.ID IS NULL, LiefArtikel.SuchCode, LiefGroe.SuchCode) AS [aktueller Lieferant],
  IIF(LiefTageGroe.ID < 0 OR LiefTageGroe.ID IS NULL, LiefTageArtikel.LiefTageBez, LiefTageGroe.LiefTageBez) AS Lieferzeiten,
  Artikel.BestNr AS Bestellnummer,
  Artikel.EkPreis AS [EK-Preis],
  ArtGroe.Groesse AS [Größe],
  [Qualität] = 
    CASE LagerArt.Neuwertig
      WHEN 1 THEN N'Neuware'
      WHEN 0 THEN N'Gebrauchtware'
      ELSE NULL
    END,
  Standort.Bez AS [Lager-Standort],
  SUM(ISNULL(Bestand.Bestand, 0)) AS Lagerbestand,
  SUM(ISNULL(Bestand.Umlauf, 0)) AS Kundenstand,
  SUM(ISNULL(Bestand.EntnahmeJahr, 0)) AS [Lagerabgang letzte 12 Monate],
  ISNULL(HadBestand.Bestand12Monate, CAST(0 AS bit)) AS [War Bestand in den letzten 12 Monaten vorhanden?],
  ISNULL(HadKundenbestand.Kunde12Monate, CAST(0 AS bit)) AS [War beim Kunden im Bestand in den letzten 12 Monaten?]
FROM Artikel
LEFT OUTER JOIN ArtGroe ON ArtGroe.ArtikelID = Artikel.ID
JOIN Farbe ON Artikel.FarbeID = Farbe.ID
JOIN Farbe AS Farbe2 ON Artikel.Farbe2ID = Farbe2.ID
JOIN ArtMust ON Artikel.ArtMustID = ArtMust.ID
JOIN ArtKoll ON Artikel.ArtKollID = ArtKoll.ID
JOIN ArtMisch ON Artikel.ArtMischID = ArtMisch.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN ProdGru ON Artikel.ProdGruID = ProdGru.ID
JOIN WaschPrg ON Artikel.WaschPrgID = WaschPrg.ID
JOIN LiefArt ON Artikel.LiefArtID = LiefArt.ID
JOIN Abc ON Artikel.AbcID = Abc.ID
JOIN ProdHier ON Artikel.ProdHierID = ProdHier.ID
JOIN Lief AS LiefArtikel ON Artikel.LiefID = LiefArtikel.ID
LEFT OUTER JOIN Lief AS LiefGroe ON ArtGroe.LiefID = LiefGroe.ID
JOIN LiefTage AS LiefTageArtikel ON Artikel.LiefTageID = LiefTageArtikel.ID
LEFT OUTER JOIN LiefTage AS LiefTageGroe ON ArtGroe.LiefTageID = LiefTageGroe.ID
LEFT OUTER JOIN Bestand ON Bestand.ArtGroeID = ArtGroe.ID
LEFT OUTER JOIN LagerArt ON Bestand.LagerArtID = LagerArt.ID
LEFT OUTER JOIN Standort ON LagerArt.LagerID = Standort.ID
LEFT OUTER JOIN HadBestand ON HadBestand.BestandID = Bestand.ID
LEFT OUTER JOIN HadKundenbestand ON HadKundenbestand.ArtGroeID = Bestand.ArtGroeID AND HadKundenbestand.LagerID = Standort.ID
WHERE Artikel.ID > 0
  AND Artikel.ArtiTypeID = 1
  AND Bestand.ID IS NOT NULL
  AND (Bestand.Bestand <> 0 OR Bestand.Umlauf <> 0 OR Bestand.EntnahmeJahr <> 0 OR HadBestand.Bestand12Monate = 1 OR HadKundenbestand.Kunde12Monate = 1)
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez, Artikel.SuchCode2, Artikel.ArtikelNr2, Farbe.FarbeBez, Farbe2.FarbeBez, ArtMust.ArtMustBez, ArtKoll.ArtKollBez, ArtMisch.ArtMischBez, Bereich.BereichBez, ArtGru.ArtGruBez, ProdGru.ProdGruBez, WaschPrg.Bez, LiefArt.LiefArtBez, Abc.ABC, Artikel.StueckGewicht, ProdHier.ProdHierBez, IIF(LiefGroe.ID < 0 OR LiefGroe.ID IS NULL, LiefArtikel.SuchCode, LiefGroe.SuchCode), IIF(LiefTageGroe.ID < 0 OR LiefTageGroe.ID IS NULL, LiefTageArtikel.LiefTageBez, LiefTageGroe.LiefTageBez), Artikel.BestNr, Artikel.EKPreis, ArtGroe.Groesse, CASE LagerArt.Neuwertig WHEN 1 THEN N'Neuware' WHEN 0 THEN N'Gebrauchtware' ELSE NULL END, Standort.Bez, ISNULL(HadBestand.Bestand12Monate, CAST(0 AS bit)), ISNULL(HadKundenbestand.Kunde12Monate, CAST(0 AS bit));