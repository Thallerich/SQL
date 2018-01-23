TRY
	DROP TABLE #TmpMöpse;
CATCH ALL END;

SELECT MAX(OpScans.Zeitpunkt) AS LastScan, OpScans.OpTeileID
INTO #TmpMöpse
FROM OpTeile
JOIN ViewArtikel Artikel ON Artikel.ID = OpTeile.ArtikelID
LEFT OUTER JOIN OpScans ON OpScans.OpTeileID = OpTeile.ID
WHERE Artikel.SuchCode LIKE 'FEUCHTWISCH%'
	AND Artikel.LanguageID = $LANGUAGE$
GROUP BY OpScans.OpTeileID;

SELECT DISTINCT Kunden.KdNr, Kunden.SuchCode, Vsa.Bez AS Vsa, OpTeile.Code, Status.Status, Status.Bez AS Stat, Artikel.ArtikelNr, Artikel.ArtikelBez, tmob.LastScan AS LetzterScan, OpTeile.AnzWasch
FROM OpTeile, ViewArtikel Artikel, #TmpMöpse tmob, Status, Vsa, Kunden
WHERE OpTeile.ArtikelID = Artikel.ID
	AND tmob.OpTeileID = OpTeile.ID
	AND OpTeile.ArtikelID = Artikel.ID
	AND OpTeile.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND OpTeile.Status = Status.Status
	AND Status.Tabelle = 'OPTEILE'
	AND CONVERT(tmob.LastScan, SQL_DATE) BETWEEN $1$ AND $2$
	AND Artikel.LanguageID = $LANGUAGE$
	AND Kunden.ID = $ID$	
ORDER BY Artikel.ArtikelNr, Status.Status, LetzterScan;

--  Summe VSA
SELECT DISTINCT Kunden.KdNr, Kunden.SuchCode, Vsa.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez, COUNT(OpTeile.Code) AS Anzahl
FROM OpTeile, ViewArtikel Artikel, #TmpMöpse tmob, Status, Vsa, Kunden
WHERE OpTeile.ArtikelID = Artikel.ID
	AND tmob.OpTeileID = OpTeile.ID
	AND OpTeile.ArtikelID = Artikel.ID
	AND OpTeile.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND OpTeile.Status = Status.Status
	AND Status.Tabelle = 'OPTEILE'
	AND CONVERT(tmob.LastScan, SQL_DATE) BETWEEN $1$ AND $2$
	AND Artikel.LanguageID = $LANGUAGE$
	AND Kunden.ID = $ID$	
GROUP BY Kunden.KdNr, Kunden.SuchCode, Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez
ORDER BY Kunden.KdNr, Vsa, Artikel.ArtikelNr;




-- Liefermengen je VSA je Monat
SELECT Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, MONTH(LsKo.Datum) + '/' + YEAR(LsKo.Datum) AS Monat, SUM(LsPo.Menge) AS Liefermenge, ViewArtikel.ArtikelNr, ViewArtikel.ArtikelBez
FROM LsPo, LsKo, Vsa, Kunden, KdArti, ViewArtikel
WHERE LsPo.LsKoID = LsKo.ID
	AND LsKo.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND LsPo.KdArtiID = KdArti.ID
	AND KdArti.ArtikelID = ViewArtikel.ID
	AND ViewArtikel.LanguageID = $LANGUAGE$
	AND Kunden.KdNr = 15100
	AND ViewArtikel.SuchCode LIKE 'FEUCHTWISCH%'
GROUP BY VsaNr, Vsa, Monat, ArtikelNr, ArtikelBez;