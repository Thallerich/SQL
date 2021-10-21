SELECT Firma.SuchCode AS Firma, KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr, Kunden.Suchcode AS Kunde, Kunden.Name1 AS Adresszeile1, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, KdArti.Variante, KdArti.VariantBez AS Variantenbezeichnung, KdArti.WaschPreis AS Bearbeitungspreis, KdArti.LeasPreis AS Mietpreis, Kundenservice.Name AS [Kundenservice-Mitarbeiter], KdArti.ID AS KdArtiID
FROM KdArti
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Mitarbei AS Kundenservice ON KdBer.ServiceID = Kundenservice.ID
WHERE KdArti.Vorlaeufig = 1 
  AND KdGf.ID IN ($1$)
  AND Firma.ID IN ($2$)
  AND Kunden.AdrArtID = 1
  AND KdArti.Status != N'I'
  AND Kunden.Status != N'I'
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
ORDER BY Kunden.KdNr, Artikel.ArtikelNr, KdArti.Variante;