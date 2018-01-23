SELECT AnfKo.LieferDatum, IIF($4$ = 1, Kunden.KdNr, NULL) AS KdNr, IIF($4$ = 1, Kunden.SuchCode, NULL) AS Kunde, IIF($5$ = 1, Vsa.Bez, NULL) AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelNr2, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, SUM(AnfPo.Angefordert) AS Angefordert, SUM(AnfPo.Geliefert) AS Geliefert, SUM(AnfPo.Angefordert - AnfPo.Geliefert) AS Gestrichen
FROM AnfPo, AnfKo, VSA, Kunden, KdArti, Artikel, StandKon
WHERE (AnfPo.Angefordert > 0 OR AnfPo.Geliefert > 0)
  AND AnfPo.AnfKoID = AnfKo.ID
  AND AnfKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND AnfPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Vsa.StandKonID = StandKon.ID
  AND StandKon.ID IN ($3$)
  AND LieferDatum BETWEEN $1$ AND $2$
  AND Artikel.BereichID IN ($6$)
GROUP BY AnfKo.LieferDatum, IIF($4$ = 1, Kunden.KdNr, NULL), IIF($4$ = 1, Kunden.SuchCode, NULL), IIF($5$ = 1, Vsa.Bez, NULL), Artikel.ArtikelNr, Artikel.ArtikelNr2, Artikel.ArtikelBez$LAN$
ORDER BY Artikel.ArtikelNr, AnfKo.LieferDatum;