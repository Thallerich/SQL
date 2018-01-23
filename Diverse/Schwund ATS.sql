DECLARE @von String;
DECLARE @bis String;

@von = '01.01.2013 00:00:00';
@bis = '31.03.2013 23:59:59';

TRY
	DROP TABLE #TmpStrumpf;
CATCH ALL END;

SELECT Strumpf.ID, Strumpf.Barcode, Strumpf.KdArtiID, Strumpf.VsaID, Strumpf.Ruecklauf, MAX(StrHist.Zeitpunkt) AS LastScan
INTO #TmpStrumpf
FROM Strumpf, StrHist, Vsa, Kunden
WHERE StrHist.StrumpfID = Strumpf.ID
	AND Strumpf.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND Kunden.KdNr = 20156
	AND Strumpf.Status <> 'X'
GROUP BY Strumpf.ID, Strumpf.Barcode, Strumpf.KdArtiID, Strumpf.VsaID, Strumpf.Ruecklauf;

SELECT DISTINCT Kunden.KdNr, Kunden.SuchCode, Vsa.Bez AS Vsa, Strumpf.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez, Strumpf.LastScan AS LetzterScan, Strumpf.Ruecklauf AS AnzWasch, 1 AS Menge
FROM #TmpStrumpf Strumpf, KdArti, ViewArtikel Artikel, Vsa, Kunden
WHERE Strumpf.KdArtiID = KdArti.ID
	AND KdArti.ArtikelID = Artikel.ID
	AND Strumpf.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND Strumpf.LastScan BETWEEN CONVERT(@von, SQL_TIMESTAMP) AND CONVERT(@bis, SQL_TIMESTAMP)
	AND Artikel.LanguageID = $LANGUAGE$
	AND Kunden.KdNr = 20156
ORDER BY Artikel.ArtikelNr, LetzterScan;