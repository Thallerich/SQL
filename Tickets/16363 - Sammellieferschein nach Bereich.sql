-- LS-Zusammenfassung (nach Datum und Bereich)

SELECT LsKo.Datum, Vsa.Bez, ViewArtikel.ArtikelNr, ViewArtikel.ArtikelBez, SUM(LsPo.Menge) AS Menge
FROM LsPo, LsKo, KdArti, ViewArtikel, Vsa, Kunden, KdBer
WHERE LsPo.LsKoID = LsKo.ID
	AND LsPo.KdArtiID = KdArti.ID
	AND KdArti.ArtikelID = ViewArtikel.ID
	AND LsKo.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND KdArti.KdBerID = KdBer.ID
	AND Vsa.ID = $ID$
	AND KdBer.BereichID IN ($2$)
	AND LsKo.Datum = $3$
	AND ViewArtikel.LanguageID = $LANGUAGE$
GROUP BY LsKo.Datum, Vsa.Bez, ViewArtikel.ArtikelNr, ViewArtikel.ArtikelBez
ORDER BY Vsa.Bez ASC, ViewArtikel.ArtikelNr ASC;