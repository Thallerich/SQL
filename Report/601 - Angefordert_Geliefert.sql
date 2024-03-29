SELECT AnfKo.LieferDatum, IIF($2$ = 1, KdGf.KurzBez, NULL) AS Geschäftsbereich, IIF($3$ = 1, Kunden.KdNr, NULL) AS KdNr, IIF($3$ = 1, Kunden.SuchCode, NULL) AS Kunde, IIF($4$ = 1, Vsa.Bez, NULL) AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelNr2, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, SUM(AnfPo.Angefordert) AS Angefordert, SUM(AnfPo.Geliefert) AS Geliefert, SUM(AnfPo.Angefordert - AnfPo.Geliefert) AS Gestrichen
FROM AnfPo, AnfKo, VSA, Kunden, KdGf, KdArti, KdBer, Artikel, StandKon, StandBer
WHERE (AnfPo.Angefordert > 0 OR AnfPo.Geliefert > 0)
  AND AnfPo.AnfKoID = AnfKo.ID
  AND AnfKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.KdGfID = KdGf.ID
  AND AnfPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND KdArti.KdBerID = KdBer.ID
  AND Vsa.StandKonID = StandKon.ID
  AND StandBer.StandKonID = StandKon.ID AND StandBer.BereichID = KdBer.BereichID
  AND StandKon.ID IN ($5$)
  AND StandBer.ProduktionID IN ($6$)
  AND LieferDatum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Artikel.BereichID IN ($7$)
GROUP BY AnfKo.LieferDatum, IIF($2$ = 1, KdGf.KurzBez, NULL), IIF($3$ = 1, Kunden.KdNr, NULL), IIF($3$ = 1, Kunden.SuchCode, NULL), IIF($4$ = 1, Vsa.Bez, NULL), Artikel.ArtikelNr, Artikel.ArtikelNr2, Artikel.ArtikelBez$LAN$
ORDER BY Artikel.ArtikelNr, AnfKo.LieferDatum;