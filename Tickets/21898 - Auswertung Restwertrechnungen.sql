SELECT Teile.Barcode, Teile.EKPreis, Teile.AusdRestw AS Restwert, Einsatz.Bezeichnung AS AusDienstGrund, Teile.ErstDatum, Teile.ErstWoche, Teile.InDienstDat AS InDienstDatum, Teile.InDienst AS InDienstWoche, Teile.AusdienstDat AS AusDienstDatum, Teile.Ausdienst AS AusDienstWoche, Bereich.Bez AS Bereich, Artikel.ArtikelNr, Artikel.ArtikelBez, Kunden.KdNr, Kunden.SuchCode AS Kunde, Firma.SuchCode AS FirmaKurz, Firma.Bez AS Firma, RKo.RechDat AS RechnungsDatum, TRIM(CONVERT(MONTH(RKo.RechDat), SQL_CHAR)) + '/' + TRIM(CONVERT(YEAR(RKo.RechDat), SQL_CHAR)) AS RechnungsMonat, RKo.RechNr
FROM Teile, RPo, RKo, ViewArtikel Artikel, ViewBereich Bereich, Vsa, Kunden, Firma, ViewEinsatz Einsatz
WHERE Teile.RPoID = RPo.ID
	AND RPo.RKoID = RKo.ID
	AND Teile.RPoID > 0
	AND RKo.RechDat BETWEEN $1$ AND $2$
	AND RPo.RPoTypeID IN (
		SELECT RPoType.ID
		FROM RPoType
		WHERE StatistikGruppe = 'Restwerte'
	)
	AND Teile.ArtikelID = Artikel.ID
	AND Artikel.BereichID = Bereich.ID
	AND Artikel.LanguageID = $LANGUAGE$
	AND Bereich.LanguageID = $LANGUAGE$
	AND Teile.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND Kunden.FirmaID = Firma.ID
	AND Teile.AusDienstGrund = Einsatz.EinsatzGrund
	AND Kunden.SichtbarID IN ($SICHTBARIDS$)
	AND Einsatz.LanguageID = $LANGUAGE$
ORDER BY Kunden.KdNr, Bereich, Artikel.ArtikelNr;