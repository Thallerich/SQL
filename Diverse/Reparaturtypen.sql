WITH Artikelstatus AS (
    SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
    FROM [Status]
    WHERE [Status].Tabelle = UPPER(N'ARTIKEL')
  )
SELECT Kürzel, Bezeichnung, [Status], Selbstkosten, Einzelpreis, Produktbereich, [mit Menge], Minuten, CAST(ISNULL([-2], 0) AS bit) AS [immer sichtbar], CAST(ISNULL([-1], 0) AS bit) AS [nicht sichtbar], CAST(ISNULL([2], 0) AS bit) AS [Umlauft KLU], CAST(ISNULL([52], 0) AS bit) AS [Wozabal Allgemein], CAST(ISNULL([55], 0) AS bit) AS Enns, CAST(ISNULL([56], 0) AS bit) AS [Bad Hofgastein], CAST(ISNULL([57], 0) AS bit) AS [Lenzing GW], CAST(ISNULL([58], 0) AS bit) AS [Lenzing IG], CAST(ISNULL([60], 0) AS bit) AS [Linz PWS], CAST(ISNULL([61], 0) AS bit) AS Budweis, CAST(ISNULL([64], 0) AS bit) AS [Wozabal und Budweis], CAST(ISNULL([65], 0) AS bit) AS Asten, CAST(ISNULL([69], 0) AS bit) AS Brasov, CAST(ISNULL([71], 0) AS bit) AS Arnoldstein, CAST(ISNULL([72], 0) AS bit) AS Mattersburg, CAST(ISNULL([73], 0) AS bit) AS Leogang, CAST(ISNULL([74], 0) AS bit) AS Grödig, CAST(ISNULL([76], 0) AS bit) AS Graz, CAST(ISNULL([77], 0) AS bit) AS Kramsach, CAST(ISNULL([78], 0) AS bit) AS [St. Pölten], CAST(ISNULL([79], 0) AS bit) AS Bratislava, CAST(ISNULL([80], 0) AS bit) AS [Enns OP], CAST(ISNULL([81], 0) AS bit) AS [ABS Migration Oct 26]
FROM (
  SELECT Artikel.ArtikelNr AS Kürzel, Artikel.ArtikelBez AS Bezeichnung, Artikelstatus.StatusBez AS [Status], Artikel.EkPreis AS Selbstkosten, Artikel.WaschPreis AS Einzelpreis, Bereich.BereichBez AS Produktbereich, [mit Menge] =
    CASE ArtiRep.MengeModus 
      WHEN 0 THEN 'nein'
      WHEN 1 THEN 'einzeln'
      WHEN 2 THEN 'Eingabe'
    END, ArtiRep.Minuten, Sichtbar.ID AS SichtbarID, CAST(1 AS tinyint) AS Sehen
  FROM Artikel
  JOIN ArtiRep ON ArtiRep.ArtikelID = Artikel.ID
  JOIN Artikelstatus ON Artikel.Status = Artikelstatus.[Status]
  JOIN Bereich ON Artikel.BereichID = Bereich.ID
  JOIN ArtiSich ON ArtiSich.ArtikelID = Artikel.ID
  JOIN Sichtbar ON ArtiSich.SichtbarID = Sichtbar.ID
  WHERE Artikel.ArtiTypeID = 5 OR Artikel.ID IS NULL
) AS RepTyp
PIVOT (
  MAX(Sehen) FOR SichtbarID IN ([-2], [-1], [2], [52], [55], [56], [57], [58], [60], [61], [64], [65], [69], [71], [72], [73], [74], [76], [77], [78], [79], [80], [81])
) AS RepPivot;