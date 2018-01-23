-- Artikeländerung (+ neue Artikel) je Quartal (über 1 Jahr zurück)
SELECT SUM(AbtKdArW.Menge) AS Menge, Wochen.Woche, TRIM(Artikel.ArtikelNr) + ' - ' + Artikel.ArtikelBez AS Artikel, CONVERT(Kunden.KdNr, SQL_VARCHAR) + ' - ' + Kunden.SuchCode AS Kunde
FROM AbtKdArW, KdArti, ViewArtikel Artikel, Kunden, Bereich, Wochen
WHERE AbtKdArW.KdArtiID = KdArti.ID
	AND KdArti.ArtikelID = Artikel.ID
	AND KdArti.KundenID = Kunden.ID
	AND Artikel.BereichID = Bereich.ID
	AND AbtKdArW.WochenID = Wochen.ID
	AND Artikel.LanguageID = $LANGUAGE$
	AND Kunden.KdNr IN (2529328, 2529332, 2529299)
	AND Bereich.Bereich = 'BK'
	AND Wochen.Monat1 > CONVERT(YEAR(CURDATE())-1, SQL_VARCHAR) + '-' + IIF(MONTH(CURDATE()) < 10, '0' + CONVERT(MONTH(CURDATE()), SQL_VARCHAR), CONVERT(MONTH(CURDATE()), SQL_VARCHAR))  -- aktueller Monat, voriges Jahr
GROUP BY Woche, Artikel, Kunde
ORDER BY Kunde, Monat, Artikel;

-- Trägeränderung (neue Träger, abgemeldete Träger)
SELECT Wochen.Woche, CONVERT(Kunden.KdNr, SQL_VARCHAR) + ' - ' + Kunden.SuchCode AS Kunde, COUNT(DISTINCT Traeger.ID) AS Traeger
FROM TraeArch, TraeArti, Traeger, Wochen, Kunden
WHERE TraeArch.TraeArtiID = TraeArti.ID
	AND TraeArti.TraegerID = Traeger.ID
	AND TraeArch.WochenID = Wochen.ID
	AND TraeArch.KundenID = Kunden.ID
	AND Kunden.KdNr IN (2529328, 2529332, 2529299)
	AND Wochen.Monat1 > CONVERT(YEAR(CURDATE())-1, SQL_VARCHAR) + '-' + IIF(MONTH(CURDATE()) < 10, '0' + CONVERT(MONTH(CURDATE()), SQL_VARCHAR), CONVERT(MONTH(CURDATE()), SQL_VARCHAR))
GROUP BY Wochen.Woche, Kunde
ORDER BY Kunde, Woche;