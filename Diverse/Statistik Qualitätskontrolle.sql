TRY
	DROP TABLE #TmpOpScansSTHA;
CATCH ALL END;

SELECT *
INTO #TmpOpScansSTHA
FROM OpScans
WHERE CONVERT(OpScans.Zeitpunkt, SQL_DATE) = $1$;

SELECT $1$ AS Datum, ZielNr.Bez AS Ziel, COUNT(*) AS Anzahl
FROM #TmpOpScansSTHA tos, ZielNr
WHERE tos.ZielNrID = ZielNr.ID
GROUP BY ZielNr.Bez
ORDER BY Ziel ASC;