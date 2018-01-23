SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, COUNT(DISTINCT Traeger.ID) AS Traeger, SUM(TraeArch.Menge) AS Menge
FROM TraeArti, TraeArch, Wochen, Kunden, Traeger, KdArti, Artikel
WHERE TraeArti.TraegerID = Traeger.ID
  AND TraeArch.TraeArtiID = TraeArti.ID
  AND TraeArch.WochenID = Wochen.ID
  AND TraeArch.KundenID = Kunden.ID
  AND TraeArti.kdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Wochen.Woche = $1$
  AND Kunden.ID = $ID$
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$
ORDER BY Artikelbezeichnung;