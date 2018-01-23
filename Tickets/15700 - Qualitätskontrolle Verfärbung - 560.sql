-- Ticket# 15700
--
-- Datumsbegrenzung von - bis
-- Begrenzung auf einen/mehrere Kunden
-- VSA-Begrenzung? evtl. nicht sinnvoll -> Rückfrage

TRY
	DROP TABLE #TmpOpScans;
CATCH ALL END;

SELECT * 
INTO #TmpOpScans 
FROM OpScans 
WHERE OpScans.ZielNrID = 10000031
	AND CONVERT(OpScans.Zeitpunkt, SQL_DATE) BETWEEN $1$ AND $2$;

SELECT ViewArtikel.ArtikelNr, ViewArtikel.ArtikelBez, OpTeile.Code, OpTeile.ErstWoche, OpTeile.AnzWasch, Vsa.Bez, Kunden.SuchCode
FROM #TmpOpScans tops, OpTeile, ViewArtikel, Vsa, Kunden
WHERE tops.OpTeileID = OpTeile.ID
	AND OpTeile.ArtikelID = ViewArtikel.ID
	AND OpTeile.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND Kunden.ID IN ($3$)
ORDER BY ViewArtikel.ArtikelNr, OpTeile.Code;