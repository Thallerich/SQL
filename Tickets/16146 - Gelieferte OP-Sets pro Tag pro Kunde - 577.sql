--Auswertung der täglich ausgelieferten bzw. gepackten OP-Artikel / Sets, welche die Setbezeichnung auflistet (Hr. Pfeil weiss Bescheid)
-- Wieviel Sets (pro Tag) an welchen Kunden.

OpEtiKo -> Artikel
OpEtiKo -> Vsa -> Kunden
OpEtiKo.PackUser LIKE '8%'

----------------------------------------------- Ausgeliefert -----------------------------------------------------------------

TRY
	DROP TABLE #TmpOpEtiKo;
CATCH ALL END;

SELECT * INTO #TmpOpEtiKo
FROM OpEtiKo
WHERE CONVERT(OpEtiKo.AusleseZeitpunkt, SQL_DATE) = $1$;

SELECT Kunden.KdNr, Kunden.SuchCode, COUNT(toek.ID) AS Menge, ViewArtikel.ArtikelNr, ViewArtikel.ArtikelBez
FROM #TmpOpEtiKo toek, ViewArtikel, Vsa, Kunden
WHERE toek.ArtikelID = ViewArtikel.ID
	AND toek.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
-- 	AND (toek.AusleseUser LIKE 'JOB%' OR toek.AusleseUser LIKE '8%')
	AND ViewArtikel.LanguageID = $LANGUAGE$
GROUP BY Kunden.KdNr, Kunden.SuchCode, ViewArtikel.ArtikelNr, ViewArtikel.ArtikelBez;

----------------------------------------------- Gepackt -----------------------------------------------------------------

TRY
	DROP TABLE #TmpOpEtiKo;
CATCH ALL END;

SELECT OpEtiKo.* INTO #TmpOpEtiKo
FROM OpEtiKo, Artikel, ProdHier
WHERE OpEtiKo.ArtikelID = Artikel.ID
	AND Artikel.ProdHierID = ProdHier.ID
	AND CONVERT(IIF(ProdHier.Bez LIKE 'Unster%', OpEtiKo.DruckZeitpunkt, OpEtiKo.PackZeitpunkt), SQL_DATE) = $1$;

SELECT Kunden.KdNr, Kunden.SuchCode, COUNT(toek.ID) AS Menge, ViewArtikel.ArtikelNr, ViewArtikel.ArtikelBez
FROM #TmpOpEtiKo toek, ViewArtikel, Vsa, Kunden
WHERE toek.ArtikelID = ViewArtikel.ID
	AND toek.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND ViewArtikel.LanguageID = $LANGUAGE$
GROUP BY Kunden.KdNr, Kunden.SuchCode, ViewArtikel.ArtikelNr, ViewArtikel.ArtikelBez;