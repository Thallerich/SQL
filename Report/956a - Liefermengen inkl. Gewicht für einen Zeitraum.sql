DROP TABLE IF EXISTS #TmpLiefermenge;
DROP TABLE IF EXISTS #TmpFinal;

SELECT LsPo.ProduktionID, LsPo.KdArtiID, SUM(LsPo.Menge) AS Menge
INTO #TmpLiefermenge
FROM LsPo, LsKo
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKo.Datum BETWEEN $1$ AND $2$
  AND LsPo.ProduktionID IN ($3$)
GROUP BY LsPo.ProduktionID, LsPo.KdArtiID;

SELECT Standort.Bez AS Produktion, Bereich.BereichBez$LAN$ AS Produktbereich, Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Liefermenge.Menge AS Liefermenge, Artikel.StueckGewicht AS [Stückgewicht in kg], Liefermenge.Menge * Artikel.StueckGewicht AS [Liefergewicht in kg]
FROM #TmpLiefermenge AS Liefermenge, Standort, KdArti, Artikel, Bereich, Kunden
WHERE LieferMenge.ProduktionID = Standort.ID
  AND LieferMenge.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Artikel.BereichID = Bereich.ID
  AND KdArti.KundenID = Kunden.ID
  AND Bereich.ID IN ($4$)
ORDER BY Produktion, KdNr, Produktbereich, ArtikelNr;