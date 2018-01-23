TRY
	DROP TABLE #TmpLieferMenge;
CATCH ALL END;

SELECT Kunden.FirmaID, Kunden.KdGfID, Kunden.KdNr, Kunden.SuchCode, Vsa.StandKonID, LsPo.ProduktionID, MONTH(LsKo.Datum) AS Monat, LsPo.KdArtiID, SUM(LsPo.Menge) AS Menge
INTO #TmpLieferMenge
FROM LsPo, LsKo, Vsa, Kunden
WHERE LsPo.LsKoID = LsKo.ID
	AND LsKo.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND Kunden.KdGfID IN ($3$)
	AND LsKo.Datum BETWEEN $1$ AND $2$
GROUP BY Kunden.FirmaID, Kunden.KdGfID, Kunden.KdNr, Kunden.SuchCode, Vsa.StandKonID, LsPo.ProduktionID, Monat, LsPo.KdArtiID;

SELECT Firma.Bez AS Firma, Standort.Bez AS Produzent, StandKon.Bez AS [Standort-Konfiguration], KdGf.KurzBez AS SGF, KdGf.Bez AS [Geschäftsfeld], LieferMenge.KdNr, LieferMenge.SuchCode AS Kunde, Bereich.Bez AS Kundenbereich, Artikel.ArtikelNr, Artikel.ArtikelBez, Liefermenge.Monat, Liefermenge.Menge AS Menge, Liefermenge.Menge * Artikel.StueckGewicht AS Liefergewicht
FROM #TmpLieferMenge LieferMenge, Firma, Standort, StandKon, KdGf, KdArti, ViewArtikel Artikel, KdBer, ViewBereich Bereich
WHERE LieferMenge.FirmaID = Firma.ID
	AND LieferMenge.ProduktionID = Standort.ID
	AND LieferMenge.StandKonID = StandKon.ID
	AND LieferMenge.KdGfID = KdGf.ID
	AND LieferMenge.KdArtiID = KdArti.ID
	AND KdArti.ArtikelID = Artikel.ID
	AND Artikel.LanguageID = $LANGUAGE$
	AND KdArti.KdBerID = KdBer.ID
	AND KdBer.BereichID = Bereich.ID
	AND Bereich.LanguageID = $LANGUAGE$;