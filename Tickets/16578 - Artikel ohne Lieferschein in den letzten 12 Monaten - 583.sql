SELECT ViewArtikel.ArtikelNr, ViewArtikel.ArtikelBez, Status.Bez AS Status, Bereich.Bez AS Bereich, MAX(LsKo.Datum) AS LetzteBest
FROM ViewArtikel, Bereich, LsPo, LsKo, KdArti, Status
WHERE ViewArtikel.BereichID = Bereich.ID
	AND ViewArtikel.ID = KdArti.ArtikelID
	AND KdArti.ID = LsPo.KdArtiID
	AND LsPo.LsKoID = LsKo.ID
	AND ViewArtikel.Status = Status.Status
	AND Status.Tabelle = 'ARTIKEL'
	AND Bereich.ID IN ($1$)
	AND TIMESTAMPDIFF(SQL_TSI_MONTH, CURDATE(), LsKo.Datum) < -12
	AND ViewArtikel.LanguageID = $LANGUAGE$
GROUP BY ViewArtikel.ArtikelNr, ViewArtikel.ArtikelBez, Status, Bereich;