SELECT AnfKo.LieferDatum, AnfKo.ID AS AnfKoID, AnfKo.AuftragsNr AS Packzettel, KdGf.KurzBez, Kunden.KdNr, Kunden.SuchCode AS Kunde, VSA.SuchCode AS VsaNr, VSA.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, AnfPo.Angefordert, AnfPo.Geliefert
FROM AnfPo, AnfKo, VSA, Kunden, KdArti, Artikel, KdGf
WHERE AnfPo.AnfKoID = AnfKo.ID
  AND AnfKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND AnfPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Kunden.KdGfID = KdGf.ID
  AND Kunden.ID = $ID$
  AND AnfKo.LieferDatum BETWEEN $1$ AND $2$
  AND (AnfPo.Angefordert > 0 OR AnfPo.Geliefert > 0)
  AND (
       ($4$ = 1 AND $5$ = 0 AND AnfPo.Angefordert >= AnfPo.Geliefert) -- Unterlieferung + vollständige Lieferung
    OR ($4$ = 1 AND $5$ = 1) -- Unterlieferung + vollständige Lieferung + Überlieferung
    OR ($4$ = 0 AND $5$ = 0 AND AnfPo.Angefordert > AnfPo.Geliefert) -- Unterlieferung
    OR ($4$ = 0 AND $5$ = 1 AND AnfPo.Angefordert <> AnfPo.Geliefert) -- Unterlieferung + Überlieferung
  )
ORDER BY AnfKo.LieferDatum, Kunden.KdNr;