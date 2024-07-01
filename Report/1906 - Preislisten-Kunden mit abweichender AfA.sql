WITH Kundenartikelstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'KDARTI'
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, KdArti.Variante, Kundenartikelstatus.StatusBez AS [Status Kundenartikel], KdArti.AfaWochen AS [AfA-Wochen Kundenartikel], KdArti.BasisRestwert AS [Basis-Restwert Kundenartikel], PrList.KdNr AS [Preisliste-Nr], PrList.Name1 AS Preisliste, PrListKdArti.AfaWochen AS [AfA-Wochen Preisliste], PrListKdArti.BasisRestwert AS [Basis-Restwert Preisliste]
FROM KdArti
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Kundenartikelstatus ON KdArti.[Status] = Kundenartikelstatus.[Status]
JOIN KdArti AS PrListKdArti ON KdArti.BasisRWPrListKdArtiID = PrListKdArti.ID
JOIN Kunden AS PrList ON PrListKdArti.KundenID = PrList.ID
WHERE KdArti.BasisRWPrListKdArtiID > 0
  AND (KdArti.AfaWochen != PrListKdArti.AfaWochen OR KdArti.BasisRestwert != PrListKdArti.BasisRestwert)
  AND Kunden.[Status] = N'A'
  AND Kunden.FirmaID IN ($1$)
  AND (($2$ = 1) OR ($2$ = 0 AND KdArti.[Status] = N'A'))
ORDER BY KdNr, ArtikelNr;