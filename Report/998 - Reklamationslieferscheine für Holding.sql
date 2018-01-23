SELECT Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, LsKo.LsNr, LsKo.Datum, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, LsPo.Menge, LsKoGruBez$LAN$ AS Reklamationsgrund
FROM LsPo, LsKo, Vsa, Kunden, Holding, KdArti, Artikel, LsKoGru
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.HoldingID = Holding.ID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND LsKo.LsKoGruID = LsKoGru.ID
  AND Holding.ID IN ($1$)
  AND LsKo.Datum BETWEEN $2$ AND $3$
  AND LsPo.Menge < 0;