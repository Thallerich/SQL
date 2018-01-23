Report 357 und Report 454 sollten die gleichen Mengen an gepackten Sets liefern, tun sie aber nicht. 


------------------------------------------- 357 -----------------------------------------------
TRY
  DROP TABLE #TempOPEtiKo;
CATCH ALL END;

SELECT * INTO #TempOPEtiKo 
FROM OPEtiKo 
WHERE convert(PackZeitpunkt,sql_date)=$1$
	OR convert(DruckZeitpunkt,sql_date)=$1$;

SELECT ArtikelBez, COUNT(*) as Anzahl, convert(IIF(ProdHier.Bez LIKE 'Unster%', DruckZeitpunkt, PackZeitpunkt),sql_date) as Datum
FROM (SELECT * FROM ViewArtikel WHERE ProdHierID IN ($3$)) a, #TempOPEtiKo OPEtiKo, PRodHier 
WHERE ProdHier.ID=a.ProdHierID 
	AND OPEtiKo.ArtikelID=a.ID
	AND convert(IIF(ProdHier.Bez LIKE 'Unster%', DruckZeitpunkt, PackZeitpunkt),sql_date)=$1$
GROUP BY ArtikelBez, Datum

UNION

SELECT 'Gesamt' as ArtikelBez, COUNT(*) as Anzahl, convert(IIF(ProdHier.Bez LIKE 'Unster%', DruckZeitpunkt, PackZeitpunkt),sql_date) as Datum
FROM (SELECT * FROM ViewArtikel WHERE ProdHierID IN ($3$)) a, #TempOPEtiKo OPEtiKo, ProdHier 
WHERE ProdHier.ID=a.ProdHierID
	AND OPEtiKo.ArtikelID=a.ID
	AND convert(IIF(ProdHier.Bez LIKE 'Unster%', DruckZeitpunkt, PackZeitpunkt),sql_date)=$1$
GROUP BY Datum

------------------------------------------ 454 -------------------------------------------------
-- Auflistung der Mitarbeiterleistung

-- 05.04.2011: Alte Auswertung wiederhergestellt, Unsterile Sets sollen hier nicht vorkommen!

TRY
	DROP TABLE #TmpOpEtiKo;
CATCH ALL END;

SELECT OpEtiKo.PackUser, COUNT(OpEtiKo.ID) AS Anzahl,  MIN(ISNULL(OpEtiKo.PackZeitpunkt, OpEtiKo.DruckZeitpunkt)) AS Anfang, MAX(ISNULL(OpEtiKo.PackZeitpunkt, OpEtiKo.DruckZeitpunkt)) AS Ende
INTO #TmpOpEtiKo
FROM OpEtiKo, Artikel, ProdHier
WHERE OpEtiKo.ArtikelID = Artikel.ID
	AND Artikel.ProdHierID = ProdHier.ID
	AND CONVERT(IIF(ProdHier.Bez LIKE 'Unster%', OpEtiKo.DruckZeitpunkt, OpEtiKo.PackZeitpunkt), SQL_DATE) = $1$
GROUP BY OpEtiKo.PackUser;

SELECT toek.PackUser AS Mitarbeiter, $1$ AS Datum, toek.Anzahl, ROUND(CONVERT(TIMESTAMPDIFF(SQL_TSI_SECOND, toek.Anfang, toek.Ende), SQL_FLOAT)/3600, 2) AS Stunden, ROUND(toek.Anzahl/(CONVERT(TIMESTAMPDIFF(SQL_TSI_SECOND, toek.Anfang, toek.Ende), SQL_FLOAT)/3600), 2) AS DurchsSetProStunde, ROUND((CONVERT(TIMESTAMPDIFF(SQL_TSI_SECOND, toek.Anfang, toek.Ende), SQL_FLOAT)/toek.Anzahl)/60, 2) AS DurchsMinutenProSet
FROM #TmpOpEtiKo toek

UNION

SELECT 'Gesamt' AS Mitarbeiter, $1$ AS Datum, SUM(toek.Anzahl) AS Anzahl, SUM(ROUND(CONVERT(TIMESTAMPDIFF(SQL_TSI_SECOND, toek.Anfang, toek.Ende), SQL_FLOAT)/3600, 2)) AS Stunden, ROUND(SUM(toek.Anzahl)/SUM(CONVERT(TIMESTAMPDIFF(SQL_TSI_SECOND, toek.Anfang, toek.Ende), SQL_FLOAT)/3600), 2) AS DurchsSetProStunde, ROUND((SUM(CONVERT(TIMESTAMPDIFF(SQL_TSI_SECOND, toek.Anfang, toek.Ende), SQL_FLOAT))/SUM(toek.Anzahl))/60, 2) AS DurchsMinutenProSet
FROM #TmpOpEtiKo toek

/* ################################################################ Alte Auswertung ###########################################
SELECT Mitarbeiter, Datum, Anzahl, round(Sekunden/3600,2) as Stunden, round(Anzahl/(Sekunden/3600),2) as DurchsSetProStunde, round((Sekunden/Anzahl)/60,2) as DurchsMinutenProSet
FROM (
	SELECT $1$ as Datum,
		OPEtiKo.PackUser as Mitarbeiter,
		sum(1) as Anzahl,
		convert(TIMESTAMPDIFF(SQL_TSI_MINUTE, min(PackZeitpunkt),max(PackZeitpunkt)), sql_float) as Minuten,
		IIF(convert(TIMESTAMPDIFF(SQL_TSI_SECOND, min(PackZeitpunkt),max(PackZeitpunkt)), sql_float)=0,1,convert(TIMESTAMPDIFF(SQL_TSI_SECOND, min(PackZeitpunkt),max(PackZeitpunkt)), sql_float)) as Sekunden
	FROM OPEtiKo
	WHERE convert(PackZeitpunkt, sql_date)=$1$
	GROUP BY 2
) a

UNION

-- Gesamtsumme aller Mitarbeiter
SELECT 'Gesamt' as Mitarbeiter, Datum, sum(Anzahl) as Anzahl, sum(round(Sekunden/3600,2)) as Stunden, round ((sum(Anzahl) / sum(Sekunden/3600)),2) as DurchsSetProStunde, round ((sum(Sekunden) / sum(Anzahl))/60, 2) as DurchsMinutenProSet
FROM (
	SELECT $1$ as Datum, PackUser as Mitarbeiter, sum(1) as Anzahl, convert(TIMESTAMPDIFF(SQL_TSI_MINUTE, min(PackZeitpunkt),max(PackZeitpunkt)), sql_float) as Minuten, convert(TIMESTAMPDIFF(SQL_TSI_SECOND, min(PackZeitpunkt),max(PackZeitpunkt)), sql_float) as Sekunden
	FROM OPEtiKo
	WHERE convert(PackZeitpunkt, sql_date)=$1$ 
	GROUP BY 2
) a
 GROUP BY 2*/