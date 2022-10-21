SELECT Traeger.PersNr AS Personalnummer, Traeger.Nachname, Traeger.Vorname, Abteil.Bez AS Kostenstelle, KdArti.VariantBez AS Berufsgruppe, Traeger.Indienst AS [Indienststellungswoche Träger], 1 AS Menge, KdArti.LeasPreis AS Periodenpreis
FROM TraeArch
JOIN TraeArti ON TraeArch.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Abteil ON TraeArch.AbteilID = Abteil.ID
JOIN Wochen ON TraeArch.WochenID = Wochen.ID
WHERE Wochen.Woche = $2$
	AND Abteil.KundenID = $1$
	AND KdArti.ArtikelID = (
		SELECT CAST(Settings.ValueMemo AS int)
		FROM Settings
		WHERE Parameter = N'ID_ARTIKEL_BERUFSGRUPPE'
	)
ORDER BY Kostenstelle, Berufsgruppe;