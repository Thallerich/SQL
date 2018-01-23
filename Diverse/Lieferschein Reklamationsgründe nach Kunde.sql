SELECT ''+$4$+' - '+$5$ AS Datumsbereich, Standort.Bez AS Standort, CONVERT(Kunden.KdNr, SQL_VARCHAR) AS Kundennummer, Kunden.SuchCode AS Kundenname, Artikel.ArtikelNr AS Artikelnummer, Artikel.ArtikelBez AS Artikelbezeichnung, LsKoGru.Bez AS Reklamationsgrund,  SUM(LsPo.Menge) AS Reklamationsmenge --, CONVERT(LsKo.Update_, sql_date) AS Reklamationsdatum
FROM Kunden, Vsa, LsKo, LsKoGru, LsPo, KdArti, ViewArtikel Artikel, Standort
WHERE Kunden.ID IN ($1$)
	AND Kunden.ID = Vsa.KundenID
	AND Vsa.ID = LsKo.VsaID
	AND LsKo.ID = LsPo.LsKoID
	AND LsKo.LsKoGruID = LsKoGru.ID
	AND LsKoGru.ID IN ($3$)
	AND LsPo.KdArtiID = KdArti.ID
	AND KdArti.ArtikelID = Artikel.ID
	AND Artikel.ID IN ($2$)
	AND Artikel.LanguageID = $LANGUAGE$
	AND LsKo.Datum BETWEEN $4$ AND $5$
	AND LsKo.ProduktionID = Standort.ID
	AND Standort.ID IN ($6$)
GROUP BY Standort, Kundennummer, Kundenname, Reklamationsgrund, Artikelnummer, Artikelbezeichnung

UNION

SELECT 'Summe:' AS Datumsbereich, '' AS Standort, '' AS Kundennummer, '' AS Kundenname, '' AS Artikelnummer, '' AS Artikelbezeichnung, '' AS Reklamationsgrund,  SUM(LsPo.Menge) AS Reklamationsmenge --, CONVERT(LsKo.Update_, sql_date) AS Reklamationsdatum
FROM Kunden, Vsa, LsKo, LsKoGru, LsPo, KdArti, ViewArtikel Artikel, Standort
WHERE Kunden.ID IN ($1$)
	AND Kunden.ID = Vsa.KundenID
	AND Vsa.ID = LsKo.VsaID
	AND LsKo.ID = LsPo.LsKoID
	AND LsKo.LsKoGruID = LsKoGru.ID
	AND LsKoGru.ID IN ($3$)
	AND LsPo.KdArtiID = KdArti.ID
	AND KdArti.ArtikelID = Artikel.ID
	AND Artikel.ID IN ($2$)
	AND Artikel.LanguageID = $LANGUAGE$
	AND LsKo.Datum BETWEEN $4$ AND $5$
	AND LsKo.ProduktionID = Standort.ID
	AND Standort.ID IN ($6$)
--GROUP BY Kundennummer, Kundenname, Reklamationsgrund, Artikelnummer, Artikelbezeichnung
--ORDER BY Kundennummer DESC