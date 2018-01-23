SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, AnfKo.AuftragsNr AS Packzettel, AnfKo.Lieferdatum, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, AnfPo.Angefordert, AnfPo.Angefordert - AnfPo.Geliefert AS [Offene Menge]
FROM AnfPo, AnfKo, Vsa, Kunden, KdArti, Artikel, ArtGru, Bereich
WHERE AnfPo.AnfKoID = AnfKo.ID
  AND AnfKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND AnfPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Artikel.ArtGruID = ArtGru.ID
  AND Artikel.BereichID = Bereich.ID
  AND Bereich.Bereich = 'OP'
  AND AnfKo.Lieferdatum = $1$
  AND ArtGru.Steril = $2$
  AND Kunden.ID = $ID$
  AND AnfPo.Angefordert - AnfPo.Geliefert <> 0
ORDER BY Packzettel, ArtikelNr;