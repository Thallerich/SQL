SELECT Kunden.KdNr, Kunden.Suchcode, Kunden.Name1, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ Artikelbezeichnung, KdArti.Variante, KdArti.WaschPreis, KdArti.LeasingPreis, KdArti.Vorlaeufig AS [Kundenartikel vorläufig?], BewAbr.Bez AS [Bewohner-Abrechnungsschema], ServiceMa.Name AS [Kundenservice-Mitarbeiter], KdArti.ID AS KdArtiID
FROM Kunden, Artikel, KdArti, KdBer, Mitarbei AS ServiceMA, BewKdAr, BewAbr
WHERE BewKdAr.Vorlaeufig = 1
  AND KdArti.ArtikelID = Artikel.ID 
  AND KdArti.KundenID = Kunden.ID 
  AND KdArti.KdBerID = KdBer.ID
  AND KdBer.ServiceID = ServiceMa.ID
  AND BewKdAr.KdArtiID = KdArti.ID
  AND BewKdAr.BewAbrID = BewAbr.ID
  AND Kunden.AdrArtID = 1
  AND KdArti.Status <> N'I'
  AND Kunden.Status <> N'I'
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
ORDER BY Kunden.KdNr, Artikel.ArtikelNr, KdArti.Variante;