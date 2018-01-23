DECLARE @von datetime = $1$;
DECLARE @bis datetime = DATEADD(day, 1, $1$);

DROP TABLE IF EXISTS #TempOPEtiKo357;

SELECT OPEtiKo.ID, OPEtiKo.ArtikelID, OPEtiKo.DruckZeitpunkt, OPEtiKo.Packzeitpunkt, OPEtiKo.ProduktionID
INTO #TempOPEtiKo357
FROM OPEtiKo
WHERE (OPEtiKo.PackZeitpunkt BETWEEN @von AND @bis OR OPEtiKo.DruckZeitpunkt BETWEEN @von AND @bis);

SELECT ArtikelBez$LAN$ AS Artikelbezeichnung, COUNT(*) AS Anzahl, CONVERT(date, IIF(ProdHier.ProdHierBez LIKE 'Unster%', OPEtiKo.DruckZeitpunkt, OPEtiKo.PackZeitpunkt)) AS Datum
FROM Artikel, ProdHier, #TempOPEtiKo357 AS OPEtiKo
WHERE Artikel.ProdHierID = ProdHier.ID
  AND OPEtiKo.ArtikelID = Artikel.ID
  AND ((ProdHier.ProdHierBez LIKE 'Unster%' AND OPEtiKo.DruckZeitpunkt BETWEEN @von AND @bis)
    OR (ProdHier.ProdHierBez NOT LIKE 'Unster%' AND OPEtiKo.PackZeitpunkt BETWEEN @von AND @bis))
  AND OpEtiKo.ProduktionID IN ($4$)
  AND ProdHier.ID IN ($3$)
GROUP BY Artikel.ArtikelBez$LAN$, CONVERT(date, IIF(ProdHier.ProdHierBez LIKE 'Unster%', OPEtiKo.DruckZeitpunkt, OPEtiKo.PackZeitpunkt))

UNION

SELECT 'ZZZ_Gesamt' as Artikelbezeichnung, COUNT(*) AS Anzahl, CONVERT(date, IIF(ProdHier.ProdHierBez LIKE 'Unster%', OPEtiKo.DruckZeitpunkt, OPEtiKo.PackZeitpunkt)) AS Datum
FROM Artikel, ProdHier, #TempOPEtiKo357 AS OPEtiKo
WHERE Artikel.ProdHierID = ProdHier.ID
  AND OPEtiKo.ArtikelID = Artikel.ID
  AND ((ProdHier.ProdHierBez LIKE 'Unster%' AND OPEtiKo.DruckZeitpunkt BETWEEN @von AND @bis)
    OR (ProdHier.ProdHierBez NOT LIKE 'Unster%' AND OPEtiKo.PackZeitpunkt BETWEEN @von AND @bis))
  AND OpEtiKo.ProduktionID IN ($4$)
  AND ProdHier.ID IN ($3$)
GROUP BY CONVERT(date, IIF(ProdHier.ProdHierBez LIKE 'Unster%', OPEtiKo.DruckZeitpunkt, OPEtiKo.PackZeitpunkt));