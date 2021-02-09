WITH KdArtiStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'KDARTI')
)
SELECT Firma.SuchCode AS Firma, KdGf.KurzBez AS SGF, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kunden.Name1, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, KdArti.Variante, KdArti.VariantBez AS Variantenbezeichnung, KdArti.Umlauf, KdArtiStatus.StatusBez AS KundenartikelStatus, KdArti.Vorlaeufig
FROM Kunden, KdArti, Artikel, KdGf, Firma, KdArtiStatus
WHERE KdArti.KundenID = Kunden.ID
  AND Kunden.KdgfID = Kdgf.ID
  AND Kunden.FirmaID = Firma.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND KdArtiStatus.Status = KdArti.Status
  AND KdGf.ID IN ($2$)
  AND KdArti.LeasingPreis = 0  
  AND KdArti.WaschPreis = 0 
  AND (KdArti.Vorlaeufig = 0 OR KdArti.Vorlaeufig = $4$)
  AND Kunden.Status IN (
    SELECT Status
    FROM Status
    WHERE ID IN ($3$)
  )
  AND Kunden.FirmaID IN ($1$)
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
ORDER BY Kunden.KdNr, Artikel.ArtikelNr;