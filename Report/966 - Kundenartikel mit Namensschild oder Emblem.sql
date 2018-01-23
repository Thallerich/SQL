SELECT 
  Kunden.KdNr, 
  Kunden.SuchCode AS Kunde, 
  Artikel.ArtikelNr, 
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, 
  Status.StatusBez$LAN$ AS [Status Kundenartikel], 
  KdArti.Variante, 
  KdArti.VariantBez AS Variantenbezeichnung, 
  CAST(IIF(KdArti.NsKdArtiID > 0, 1, 0) AS bit) AS [Namenschild?], 
  CAST(IIF(KdArti.EmbKdArtiID > 0, 1, 0) AS bit) AS [Emblem?],
  KdArti.ID AS KdArtiID               -- um im AdvanTex direkt zum Kundenartikel springen zu können; wird nicht angezeigt / exportiert
FROM KdArti
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Status ON KdArti.Status = Status.Status AND Status.Tabelle = N'KDARTI'
WHERE Kunden.AdrArtID = 1             -- nur tatsächliche Kunden
  AND Kunden.Status = N'A'            -- nur aktive Kunden
  AND (KdArti.NsKdArtiID > 0 OR KdArti.EmbKdArtiID > 0)