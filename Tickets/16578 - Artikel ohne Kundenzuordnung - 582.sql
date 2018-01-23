SELECT ViewArtikel.ArtikelNr, ViewArtikel.ArtikelBez, Status.Bez, KdArti.ID
FROM ViewArtikel
LEFT OUTER JOIN KdArti ON (KdArti.ArtikelID = ViewArtikel.ID)
LEFT OUTER JOIN Bereich ON (Bereich.ID = ViewArtikel.BereichID)
LEFT OUTER JOIN Status ON (ViewArtikel.Status = Status.Status)
WHERE Bereich.ID IN ($1$)
	AND ViewArtikel.LanguageID = $LANGUAGE$
	AND Status.Tabelle = 'ARTIKEL'
GROUP BY ViewArtikel.ArtikelNr, ViewArtikel.ArtikelBez, Status.Bez, KdArti.ID
HAVING KdArti.ID IS NULL;
