SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, KdArti.Variante AS V, KdArti.VariantBez AS Variante, SUM(RechPo.Menge) AS Menge
FROM RechPo
JOIN KdArti ON RechPo.KdArtiID = KdArti.ID AND RechPo.KdArtiID > 0
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
WHERE RechKo.RechDat BETWEEN $1$ AND $2$
  AND Artikel.ID = (SELECT CAST(ValueMemo AS int) FROM Settings WHERE Settings.Parameter = N'ID_ARTIKEL_BERUFSGRUPPE')
GROUP BY Kunden.Kdnr, Kunden.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez, KdArti.Variante, KdArti.VariantBez;