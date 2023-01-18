WITH KdArtiStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'KDARTI')
)
SELECT 
  Standort.SuchCode AS Hauptstandort,
  KdGf.KurzBez AS SGF,
  Kunden.KdNr, 
  Kunden.SuchCode AS Kunde, 
  Artikel.ArtikelNr, 
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, 
  KdArtiStatus.StatusBez AS [Status Kundenartikel], 
  KdArti.Variante, 
  KdArti.VariantBez AS Variantenbezeichnung, 
  CAST(IIF(NsAppl.ID IS NOT NULL, 1, 0) AS bit) AS [Namenschild?],
  COUNT(DISTINCT NsAppl.ID) AS [Anzahl Namenschilder],
  CAST(IIF(EmblAppl.ID IS NOT NULL, 1, 0) AS bit) AS [Emblem?],
  COUNT(DISTINCT EmblAppl.ID) AS [Anzahl Embleme],
  KdArti.ID AS KdArtiID               -- um im AdvanTex direkt zum Kundenartikel springen zu können; wird nicht angezeigt / exportiert
FROM KdArti
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN KdArtiStatus ON KdArti.Status = KdArtiStatus.Status
LEFT JOIN KdArAppl AS NsAppl ON NsAppl.KdArtiID = KdArti.ID AND NsAppl.ArtiTypeID = 2
LEFT JOIN KdArAppl AS EmblAppl ON EmblAppl.KdArtiID = KdArti.ID AND EmblAppl.ArtiTypeID = 3
WHERE Kunden.AdrArtID = 1             -- nur tatsächliche Kunden
  AND Kunden.Status = N'A'            -- nur aktive Kunden
  AND Standort.ID IN ($1$)
  AND KdGf.ID IN ($2$)
  AND (NsAppl.ID IS NOT NULL OR EmblAppl.ID IS NOT NULL)
GROUP BY Standort.SuchCode, KdGf.KurzBez, Kunden.KdNr, Kunden.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, KdArtiStatus.StatusBez, KdArti.Variante, KdArti.VariantBez, CAST(IIF(NsAppl.ID IS NOT NULL, 1, 0) AS bit), CAST(IIF(EmblAppl.ID IS NOT NULL, 1, 0) AS bit), KdArti.ID;