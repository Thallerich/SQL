WITH KdArtiStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'KDARTI')
)
SELECT 
  Kunden.KdNr, 
  Kunden.SuchCode AS Kunde, 
  Artikel.ArtikelNr, 
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, 
  KdArtiStatus.StatusBez AS [Status Kundenartikel], 
  KdArti.Variante, 
  KdArti.VariantBez AS Variantenbezeichnung, 
  CAST(IIF(NsAppl.ID IS NOT NULL, 1, 0) AS bit) AS [Namenschild?], 
  CAST(IIF(EmblAppl.ID IS NOT NULL, 1, 0) AS bit) AS [Emblem?],
  KdArti.ID AS KdArtiID               -- um im AdvanTex direkt zum Kundenartikel springen zu können; wird nicht angezeigt / exportiert
FROM KdArti
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdArtiStatus ON KdArti.Status = KdArtiStatus.Status
LEFT JOIN KdArAppl AS NsAppl ON NsAppl.KdArtiID = KdArti.ID AND NsAppl.ArtiTypeID = 2
LEFT JOIN KdArAppl AS EmblAppl ON EmblAppl.KdArtiID = KdArti.ID AND EmblAppl.ArtiTypeID = 3
WHERE Kunden.AdrArtID = 1             -- nur tatsächliche Kunden
  AND Kunden.Status = N'A'            -- nur aktive Kunden
  AND (NsAppl.ID IS NOT NULL OR EmblAppl.ID IS NOT NULL);