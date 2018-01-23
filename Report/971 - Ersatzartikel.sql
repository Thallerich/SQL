SELECT KdGf.KurzBez AS SGF, Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, EArtikel.ArtikelNr AS ErsatzartikelNr, EArtikel.ArtikelBez$LAN$ AS Ersatzartikelbezeichnung
FROM KdArti, Kunden, KdGf, Artikel, KdArti AS EKdArti, Artikel AS EArtikel
WHERE KdArti.KundenID = Kunden.ID
  AND Kunden.KdGfID = KdGf.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND EKdArti.ErsatzFuerKdArtiID = KdArti.ID
  AND EKdArti.ArtikelID = EArtikel.ID
  AND EKdArti.ErsatzFuerKdArtiID > 0
  AND KdGf.ID IN ($1$)
ORDER BY SGF, Kunden.KdNr, Artikel.ArtikelNr, EArtikel.ArtikelNr;