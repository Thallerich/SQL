SELECT Expedition.SuchCode AS Expedition, AnfKo.Lieferdatum, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, IIF($5$ = 1, Kunden.KdNr, NULL) AS KdNr, IIF($5$ = 1, Kunden.SuchCode, NULL) AS Kunde, IIF($5$ = 1, ABC.ABC, NULL) AS [ABC-Klasse Kunde], IIF($6$ = 1, Vsa.Bez, NULL) AS VSA, SUM(AnfPo.Angefordert) AS Bestellt, ROUND(SUM(VsaAnf.Durchschnitt) / COUNT(DISTINCT Vsa.ID), 0) AS Durchschnitt, SUM(AnfPo.Geliefert) AS Geliefert, SUM(AnfPo.Angefordert - AnfPo.Geliefert) AS [noch Offen], Artikel.Stueckgewicht, SUM(AnfPo.Angefordert - AnfPo.Geliefert) * Artikel.StueckGewicht AS [noch Offen kg]
FROM AnfPo, AnfKo, Vsa, Kunden, ABC, KdArti, Artikel, VsaAnf, VsaTour, Touren, Standort AS Expedition
WHERE AnfPo.AnfKoID = AnfKo.ID
  AND AnfKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.ABCID = ABC.ID
  AND AnfPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND VsaAnf.VsaID = Vsa.ID
  AND VsaAnf.KdArtiID = AnfPo.KdArtiID
  AND VsaAnf.ArtGroeID = AnfPo.ArtGroeID
  AND VsaTour.VsaID = Vsa.ID
  AND VsaTour.KdBerID = KdArti.KdBerID
  AND VsaTour.TourenID = Touren.ID
  AND Touren.ExpeditionID = Expedition.ID
  AND Expedition.ID IN ($2$)
  AND AnfKo.Lieferdatum BETWEEN $3$ AND $4$
GROUP BY Expedition.SuchCode, AnfKo.Lieferdatum, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, IIF($5$ = 1, Kunden.KdNr, NULL), IIF($5$ = 1, Kunden.SuchCode, NULL), IIF($5$ = 1, ABC.ABC, NULL), IIF($6$ = 1, Vsa.Bez, NULL), Artikel.StueckGewicht
HAVING SUM(AnfPo.Angefordert - AnfPo.Geliefert) > 0
ORDER BY AnfKo.Lieferdatum ASC;