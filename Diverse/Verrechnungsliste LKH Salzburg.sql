SELECT Traeger.Nachname, Traeger.Vorname, Abteil.Bez AS Kostenstelle, KdArti.VariantBez AS Berufsgruppe, 1 AS Menge, KdArti.PeriodenPreis
FROM Abteil, Traeger, Kunden, KdArti, (
	SELECT TraeArti.TraegerID, TraeArch.AbteilID
	FROM TraeArti, TraeArch, ArtGroe, Wochen
	WHERE TraeArch.WochenID = Wochen.ID 
		AND Wochen.Woche = $2$
		AND TraeArch.TraeArtiID = TraeArti.ID 
		AND TraeArti.ArtGroeID = ArtGroe.ID 
		AND TraeArch.AbteilID IN (
			SELECT RPo.AbteilID
			FROM RPo, RKo
			WHERE RPo.RKoID = RKo.ID
                        AND RKo.RechNr = $4$
		)
	GROUP BY 1, 2) Daten
WHERE Abteil.ID = Daten.AbteilID 
AND Traeger.ID = Daten.TraegerID 
AND Abteil.KundenID = Kunden.ID 
AND Traeger.BerufsgrKdArtiID = KdArti.ID
AND Traeger.Status NOT IN ('P', 'K')
AND Traeger.InDienst <= $2$
AND IFNULL(Traeger.AusDienst, '2099/52') >= $1$
ORDER BY Kostenstelle, Berufsgruppe

----------------------------------------------------------- vv Von AdvanTex vv ---------------------------------------------------------------------

SELECT Traeger.ID, Traeger.Nachname, Traeger.Vorname, Abteil.Bez AS Kostenstelle, KdArti.VariantBez AS Berufsgruppe, 1 AS Menge, KdArti.PeriodenPreis
FROM traeger, Abteil, KdArti 
WHERE berufsgrkdartiid IN (
	SELECT 
	k.ID
	FROM KdArti k, Artikel a, LangBez Lb
	WHERE k.ArtikelID = a.ID
		AND a.ID = Lb.TableID
		AND Lb.TableName = 'ARTIKEL'
		AND lb.LanguageID = -1
		AND k.KundenID = $3$ --> Kunde
		AND lb.Bez = 'Berufsgruppe'
	)
	AND traeger.berufsgrkdartiid = kdarti.id
	AND traeger.abteilid = abteil.id
	AND indienst <= $1$
	AND IIF(ausdienst IS NULL, '2099-12', ausdienst) > $2$ --> vonWoche BisWoche
	AND traeger.status IN ('A', 'I')
ORDER BY Kostenstelle, Berufsgruppe