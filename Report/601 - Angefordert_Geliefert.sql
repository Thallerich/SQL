SELECT AnfKo.LieferDatum, IIF($2$ = 1, Kunden.KdNr, NULL) AS KdNr, IIF($2$ = 1, Kunden.SuchCode, NULL) AS Kunde, IIF($3$ = 1, Vsa.Bez, NULL) AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelNr2, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, SUM(AnfPo.Angefordert) AS Angefordert, SUM(AnfPo.Geliefert) AS Geliefert, SUM(AnfPo.Angefordert - AnfPo.Geliefert) AS Gestrichen
FROM AnfPo, AnfKo, VSA, Kunden, KdArti, KdBer, Artikel, StandKon, StandBer
WHERE (AnfPo.Angefordert > 0 OR AnfPo.Geliefert > 0)
  AND AnfPo.AnfKoID = AnfKo.ID
  AND AnfKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND AnfPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND KdArti.KdBerID = KdBer.ID
  AND Vsa.StandKonID = StandKon.ID
  AND StandBer.StandKonID = StandKon.ID AND StandBer.BereichID = KdBer.BereichID
  AND StandKon.ID IN ($4$)
  AND StandBer.ProduktionID IN ($5$)
  AND LieferDatum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Artikel.BereichID IN ($6$)
GROUP BY AnfKo.LieferDatum, IIF($2$ = 1, Kunden.KdNr, NULL), IIF($2$ = 1, Kunden.SuchCode, NULL), IIF($3$ = 1, Vsa.Bez, NULL), Artikel.ArtikelNr, Artikel.ArtikelNr2, Artikel.ArtikelBez$LAN$
ORDER BY Artikel.ArtikelNr, AnfKo.LieferDatum;