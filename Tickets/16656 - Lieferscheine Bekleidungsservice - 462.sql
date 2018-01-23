TRY
	DROP TABLE #TmpScans;
CATCH ALL END;

SELECT Scans.ID, Scans.TeileID, Scans.DateTime
INTO #TmpScans
FROM Scans
WHERE CONVERT(Scans.DateTime, SQL_DATE) BETWEEN $2$ AND $3$
  AND Scans.ZielNrID = 41;

SELECT kunden.kdnr,  kunden.suchcode, vsa.bez, traeger.nachname, traeger.vorname, teile.barcode, scans.datetime, teile.artikelID, vsa.standkonID, teile.einsatzgrund, langbez.bez
FROM #TmpScans scans, teile, traeger,vsa, kunden, langbez, artikel
WHERE scans.teileID=Teile.ID
	AND teile.traegerID=traeger.ID 
	AND teile.vsaID=vsa.ID
	AND vsa.kundenID=kunden.ID
	AND teile.artikelID=artikel.ID
	AND langbez.tableID=Artikel.ID 
	AND langbez.languageID=$LANGUAGE$
	--AND scans.ZielNrID=41
	--AND CONVERT(DateTime, sql_date) BETWEEN $2$ AND $3$
	AND vsa.standkonID IN ($1$)
	AND teile.einsatzgrund IN ('1','2','3','4','5','B','b','C','c','D','d')
ORDER by 1;