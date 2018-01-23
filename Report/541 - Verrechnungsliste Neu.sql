SELECT Traeger.Nachname, Traeger.Vorname, Abteil.Bez AS Kostenstelle, KdArti.VariantBez AS Berufsgruppe, 1 AS Menge, KdArti.PeriodenPreis
FROM KdArti, Abteil, Traeger, Kunden, TraeArti, TraeArch, Wochen
WHERE TraeArch.WochenID = Wochen.ID
	AND Wochen.Woche = $2$
	AND Kunden.ID = $1$
	AND TraeArch.TraeArtiID = TraeArti.ID
	AND KdArti.ID = TraeArti.KdArtiID
	AND KdArti.ArtikelID = (
		SELECT CONVERT(integer, ValueMemo)
		FROM Settings
		WHERE Parameter = 'ID_ARTIKEL_BERUFSGRUPPE'
	)
	AND Abteil.ID = TraeArch.AbteilID
	AND Traeger.ID = TraeArti.TraegerID
	AND Abteil.KundenID = Kunden.ID
ORDER BY Kostenstelle, Berufsgruppe;