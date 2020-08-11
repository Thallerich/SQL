SELECT AnfKo.LieferDatum, KdGf.KurzBez, Kunden.KdNr, Kunden.SuchCode AS Kunde, VSA.SuchCode AS VsaNr, VSA.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, AnfPo.Angefordert, AnfPo.Geliefert, AnfPo.Geliefert - AnfPo.Angefordert AS Differenz, round(IIF(AnfPo.Angefordert <> 0, 100 / AnfPo.Angefordert * AnfPo.Geliefert, null), 0) AS Lieferquote, Expedition.SuchCode AS Expedition
FROM AnfPo, AnfKo, VSA, Kunden, KdArti, Artikel, VsaTour, Touren, Standort AS Expedition, KdGf
WHERE (
     ($4$ = 0 AND $5$ = 0 AND AnfPo.Geliefert - AnfPo.Angefordert < 0)
  OR ($4$ = 0 AND $5$ = 1 AND AnfPo.Geliefert - AnfPo.Angefordert <> 0)
  OR ($4$ = 1 AND $5$ = 0 AND AnfPo.Geliefert - AnfPo.Angefordert <= 0)
  OR ($4$ = 1 AND $5$ = 1)
)
  AND (AnfPo.Angefordert > 0 OR AnfPo.Geliefert > 0)
  AND AnfPo.AnfKoID = AnfKo.ID
  AND AnfKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND AnfPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND VsaTour.VsaID = Vsa.ID
  AND VsaTour.KdBerID = KdArti.KdBerID
  AND VsaTour.TourenID = Touren.ID
  AND Touren.ExpeditionID = Expedition.ID
  AND Kunden.KdGfID = KdGf.ID
  AND Expedition.ID IN ($3$)
  AND LieferDatum BETWEEN $1$ AND $2$
ORDER BY AnfKo.LieferDatum, Kunden.KdNr;