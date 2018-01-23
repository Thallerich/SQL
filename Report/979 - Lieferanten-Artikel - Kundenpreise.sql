SELECT Lief.LiefNr, Lief.SuchCode AS Lieferant, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Artikel.EKPreis, KdGf.KurzBez AS SGF, Kunden.KdNr, Kunden.SuchCode AS Kunde, KdArti.WaschPreis, KdArti.LeasingPreis
FROM KdArti, Kunden, KdGf, Artikel, Lief
WHERE KdArti.KundenID = Kunden.ID
  AND Kunden.KdGfID = KdGf.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Artikel.LiefID = Lief.ID
  AND KdArti.Status = 'A'
  AND Lief.ID = $ID$
  AND (KdArti.WaschPreis <> 0 OR KdArti.LeasingPreis <> 0)
ORDER BY Lief.LiefNr, Artikel.ArtikelNr, Kunden.KdNr;