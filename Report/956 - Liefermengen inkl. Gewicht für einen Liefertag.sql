BEGIN TRY
  DROP TABLE #TmpLiefermenge;
  DROP TABLE #TmpFinal;
END TRY
BEGIN CATCH
END CATCH;

SELECT LsPo.ProduktionID, LsPo.KdArtiID, SUM(LsPo.Menge) AS Menge
INTO #TmpLiefermenge
FROM LsPo, LsKo
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKo.Datum = $1$
  AND LsPo.ProduktionID IN ($2$)
GROUP BY LsPo.ProduktionID, LsPo.KdArtiID;

SELECT $1$ AS Lieferdatum, Standort.Bez AS Produktion, Bereich.BereichBez$LAN$ AS Produktbereich, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Liefermenge.Menge AS Liefermenge, Artikel.StueckGewicht AS [Stückgewicht in kg], Liefermenge.Menge * Artikel.StueckGewicht AS [Liefergewicht in kg]
INTO #TmpFinal
FROM #TmpLiefermenge AS Liefermenge, Standort, KdArti, Artikel, Bereich
WHERE LieferMenge.ProduktionID = Standort.ID
  AND LieferMenge.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Artikel.BereichID = Bereich.ID
  AND Bereich.ID IN ($3$);

SELECT Lieferdatum, Produktion, Produktbereich, ArtikelNr, Artikelbezeichnung, Liefermenge, [Stückgewicht in kg], [Liefergewicht in kg]
FROM #TmpFinal

UNION ALL

SELECT Lieferdatum, 'ZSumme' AS Produktion, '' AS Produktbereich, '' AS ArtikelNr, '' AS Artikelbezeichnung, SUM(Liefermenge) AS Liefermenge, 0 AS [Stückgewicht in kg], SUM([Liefergewicht in kg]) AS [Liefergewicht in kg]
FROM #TmpFinal
GROUP BY Lieferdatum
ORDER BY Produktion, Produktbereich, ArtikelNr;