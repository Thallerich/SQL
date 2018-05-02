SELECT LsKo.Datum, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Kunden.KdNr, Kunden.Name1, Vsa.VsaNr, Vsa.Bez AS VSA, Vsa.SuchCode AS VsaStichwort, Wiegung.Netto, KdArti.Variante, LsKo.LsNr, Contain.Barcode AS Container
FROM Wiegung, LsPo, LsKo, Vsa, Kunden, KdArti, Artikel, Contain
WHERE Wiegung.LsPoID = LsPo.ID
  AND LsPo.LsKoID = LsKo.ID
  AND LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Wiegung.ContainID = Contain.ID
  AND Kunden.ID = $ID$
  AND LsKo.Datum BETWEEN $1$ AND $2$
ORDER BY LsKo.Datum;