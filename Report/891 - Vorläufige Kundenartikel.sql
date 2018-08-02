SELECT Kunden.KdNr, Kunden.Suchcode, Kunden.Name1, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ Artikelbezeichnung, KdArti.Variante, KdArti.WaschPreis, KdArti.LeasingPreis, ServiceMa.Name AS [Kundenservice-Mitarbeiter], KdArti.ID AS KdArtiID
FROM Kunden, Artikel, KdArti, KdBer, Mitarbei AS ServiceMA
WHERE KdArti.Vorlaeufig = $TRUE$ 
  AND KdArti.ArtikelID = Artikel.ID 
  AND KdArti.KundenID = Kunden.ID 
  AND KdArti.KdBerID = KdBer.ID
  AND KdBer.ServiceID = ServiceMa.ID
  AND Kunden.KdGfID IN ($1$) 
ORDER BY Kunden.KdNr, Artikel.ArtikelNr, KdArti.Variante;