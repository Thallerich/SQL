TRY
	DROP TABLE #tempscans1;
CATCH ALL END;

SELECT *
INTO #tempscans1
FROM OpScans
WHERE CONVERT(OpScans.Zeitpunkt, SQL_DATE) = $1$
  AND OpScans.ZielNrID = 10000009;

SELECT ts1.AnlageUser_ AS Benutzer, SUM(1) AS Menge, ViewArtikel.ArtikelNr, ViewArtikel.ArtikelBez
FROM #tempscans1 ts1, OpTeile, ViewArtikel
WHERE ts1.OpTeileID = OpTeile.ID
  AND OpTeile.ArtikelID = ViewArtikel.ID
  AND ViewArtikel.LanguageID = $LANGUAGE$
GROUP BY Benutzer, ArtikelNr, ArtikelBez;