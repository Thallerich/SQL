SELECT Firma.Bez AS Firma, Produktion.Bez AS Produktionsstandort, Expedition.Bez AS Expeditionsstandort, Bereich.Bereich, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Wae.Code AS Währung, InKalk.InKalkWaschPreis AS [Bearbeitung fest], InKalk.InKalkWaschProzent AS [Bearbeitung %], InKalk.InKalkLeasPreis AS [Leasing fest], InKalk.InKalkLeasProzent AS [Leasing %], InKalk.InKalkSplitPreis AS [Split fest], InKalk.InKalkSplitProzent AS [Split %]
FROM InKalk
JOIN Firma ON InKalk.FirmaID = Firma.ID
JOIN Standort AS Produktion ON InKalk.ProduktionID = Produktion.ID
JOIN Standort AS Expedition ON InKalk.ExpeditionID = Expedition.ID
JOIN Bereich ON InKalk.BereichID = Bereich.ID
JOIN Artikel ON InKalk.ArtikelID = Artikel.ID
JOIN Wae ON InKalk.WaeID = Wae.ID
WHERE Firma.SuchCode = N'FA14'
  AND InKalk.KundenID < 0
  AND ((Artikel.ID > 0 AND Artikel.ArtiTypeID = 1) OR (Artikel.ID < 0))
  AND (InKalk.ProduktionID > 0 OR InKalk.ExpeditionID > 0 OR InKalk.BereichID > 0 OR InKalk.ArtikelID > 0 OR InKalk.WaeID > 0)
  AND (
    (InKalk.InKalkWaschPreis = 0 AND InKalk.InKalkWaschProzent = 0) OR
    (InKalk.InKalkLeasPreis = 0 AND InKalk.InKalkLeasProzent = 0) OR
    (InKalk.InKalkSplitPreis = 0 AND InKalk.InKalkSplitProzent = 0)
  )

GO

SELECT Firma.Bez AS Firma, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, InKalk.InKalkWaschPreis AS [Bearbeitung fest], InKalk.InKalkWaschProzent AS [Bearbeitung %], InKalk.InKalkLeasPreis AS [Leasing fest], InKalk.InKalkLeasProzent AS [Leasing %], InKalk.InKalkSplitPreis AS [Split fest], InKalk.InKalkSplitProzent AS [Split %], CAST(80 AS tinyint) AS [Split % neu]
FROM InKalk
JOIN Firma ON InKalk.FirmaID = Firma.ID
JOIN Artikel ON InKalk.ArtikelID = Artikel.ID
WHERE Firma.SuchCode = N'FA14'
  AND InKalk.KundenID < 0
  AND Artikel.ID > 0
  AND Artikel.BereichID = (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = N'BK')
  AND InKalk.InKalkSplitPreis = 0
  AND InKalk.InKalkSplitProzent = 0;

GO

UPDATE InKalk SET InKalkSplitProzent = 80
WHERE ID IN (
  SELECT InKalk.ID
  FROM InKalk
  JOIN Firma ON InKalk.FirmaID = Firma.ID
  JOIN Artikel ON InKalk.ArtikelID = Artikel.ID
  WHERE Firma.SuchCode = N'FA14'
    AND InKalk.KundenID < 0
    AND Artikel.ID > 0
    AND Artikel.BereichID = (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = N'BK')
    AND InKalk.InKalkSplitPreis = 0
    AND InKalk.InKalkSplitProzent = 0
);

GO