TRY
  DROP TABLE #TempOPEtiKo;
CATCH ALL END;

SELECT * INTO #TempOPEtiKo FROM OPEtiKo WHERE convert(PackZeitpunkt,sql_date)=$1$ or 
                                              convert(DruckZeitpunkt,sql_date)=$1$;

SELECT ArtikelBez, COUNT(*) as Anzahl, convert(IIF(ProdHier.Bez LIKE 'Unster%', DruckZeitpunkt, PackZeitpunkt),sql_date) as Datum
FROM (SELECT * FROM ViewArtikel WHERE ProdHierID IN ($3$)) a, #TempOPEtiKo OPEtiKo, PRodHier 
WHERE ProdHier.ID=a.ProdHierID and OPEtiKo.ArtikelID=a.ID and 
      convert(IIF(ProdHier.Bez LIKE 'Unster%', DruckZeitpunkt, PackZeitpunkt),sql_date)=$1$
GROUP BY ArtikelBez, Datum

UNION

SELECT 'Gesamt' as ArtikelBez, COUNT(*) as Anzahl, 
       convert(IIF(ProdHier.Bez LIKE 'Unster%', DruckZeitpunkt, PackZeitpunkt),sql_date) as Datum
FROM (SELECT * FROM ViewArtikel WHERE ProdHierID IN ($3$)) a, #TempOPEtiKo OPEtiKo, PRodHier 
WHERE ProdHier.ID=a.ProdHierID and OPEtiKo.ArtikelID=a.ID and 
      convert(IIF(ProdHier.Bez LIKE 'Unster%', DruckZeitpunkt, PackZeitpunkt),sql_date)=$1$
GROUP BY Datum
