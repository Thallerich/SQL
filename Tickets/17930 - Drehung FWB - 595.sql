TRY
	DROP TABLE #TmpMöpse;
CATCH ALL END;

SELECT MAX(OpScans.Zeitpunkt) AS LastScan, OpScans.OpTeileID
INTO #TmpMöpse
FROM OpTeile
JOIN ViewArtikel Artikel ON Artikel.ID = OpTeile.ArtikelID
JOIN Bereich ON Bereich.ID = Artikel.BereichID
LEFT OUTER JOIN OpScans ON OpScans.OpTeileID = OpTeile.ID
WHERE Bereich.Bereich = 'FB'
	AND Artikel.LanguageID = $LANGUAGE$
GROUP BY OpScans.OpTeileID;

SELECT OpTeile.Code, Status.Status, Status.Bez AS Stat, Artikel.ArtikelNr, Artikel.ArtikelBez, tmob.LastScan AS LetzterScan
FROM OpTeile, ViewArtikel Artikel, #TmpMöpse tmob, Status
WHERE OpTeile.ArtikelID = Artikel.ID
	AND tmob.OpTeileID = OpTeile.ID
	AND OpTeile.ArtikelID = Artikel.ID
	AND OpTeile.Status = Status.Status
	AND Status.Tabelle = 'OPTEILE'
	AND TIMESTAMPDIFF(SQL_TSI_MONTH, tmob.LastScan, NOW()) >= $1$
	AND Artikel.LanguageID = $LANGUAGE$	
ORDER BY Artikel.ArtikelNr, Status.Status, LetzterScan;