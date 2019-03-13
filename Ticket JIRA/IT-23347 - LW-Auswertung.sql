WITH KdArtiStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'KDARTI')
)
SELECT Firma.Bez AS Firma, Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, KdArti.Variante, ISNULL(KdArti.VariantBez, N'') AS Variantenbezeichnung, KdArtiStatus.StatusBez AS [Kundenartikel-Status], KdArti.Vorlaeufig, KdArti.WaschPreis AS Bearbeitungspreis, KdArti.LeasingPreis AS [Leasing-Preis]
FROM KdArti
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdArtiStatus ON KdArtiStatus.[Status] = KdArti.[Status]
WHERE LEFT(Artikel.ArtikelNr, 2) IN (N'SC', N'SV', N'SW')
  AND Firma.SuchCode = N'SAL';