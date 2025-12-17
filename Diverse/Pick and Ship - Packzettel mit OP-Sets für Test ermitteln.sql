SELECT OPEtiKo.EtiNr, OPEtiKo.VerfallDatum, Artikel.ArtikelNr, Artikel.ArtikelBez, AnfKo.AuftragsNr, AnfKo.Lieferdatum, Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Bez
FROM AnfPo
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN OPEtiKo ON OPEtiKo.ArtikelID = Artikel.ID
JOIN Vsa ON AnfKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE OPEtiKo.[Status] = 'M'
  AND OPEtiKo.VerfallDatum > CAST(GETDATE() AS date)
  AND AnfKo.[Status] = 'I'
  AND AnfKo.Lieferdatum > CAST(GETDATE() AS date)
  AND AnfKo.ProduktionID = 4
  AND AnfPo.Angefordert > 0;