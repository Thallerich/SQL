SELECT Daten.Datum, Daten.KdNr, Daten.VsaName, Artikel.ArtikelNr, Langbez.Bez AS Bezeichnung, Daten.Anzahl_Ruecklaufbestellung AS Rücklaufbestellung, DatenLS.Anzahl_geliefert AS Geliefert
FROM (
		SELECT vsa.VsaNr, vsa.name1 VsaName, kunden.KdNr, kunden.name1 KdName, OpEtiKo.ArtikelID, CONVERT(opetiko.anlage_, sql_date) AS Datum, COUNT(*) Anzahl_Ruecklaufbestellung
		FROM OpEtiKo, Vsa, Kunden, (
			SELECT DISTINCT CONVERT(TRIM(SUBSTRING(memo, 11, 50)), SQL_INTEGER) OpEtiKoID
			FROM logitem
			WHERE bez = 'Einlesen OP-Teil => neue Anforderung für OP-Set'
		) logitem
		WHERE LogItem.OpEtiKoID = OpEtiKo.ID
		AND opetiko.vsaid = vsa.id
		AND vsa.kundenid = kunden.id
	 
-- in der nachfolgenden Zeile bitte das Erstellungsdatum der OP-Sets sowie den
-- Kunden bzw. die VSA eingrenzen
-- and vsa.vsanr = 14
	 
		AND kunden.kdnr = 2300
		AND opetiko.anlage_ BETWEEN '2010-08-01 00:00:00' AND '2010-10-01 00:00:00'
		GROUP BY 1,2,3,4,5,6
	) Daten,
	(
		SELECT LSKO.Datum, KUNDEN.KdNr, KDARTI.ArtikelID, SUM(LSPO.Menge) AS Anzahl_geliefert
		FROM LSPO, LSKO, KDARTI, KUNDEN
		WHERE LSKO.ID = LSPO.LsKoID
		AND LSKO.Datum BETWEEN '2010-08-01' AND '2010-10-01'
		AND LSPO.KdArtiID = KDARTI.ID
		AND KDARTI.KundenID = KUNDEN.ID
		AND KUNDEN.KdNr = 2300
		GROUP BY 1,2,3
	) DatenLS,
	artikel, langbez
	WHERE Daten.artikelid = artikel.id
	AND langbez.tablename = 'ARTIKEL'
	AND langbez.tableID = artikel.id
	AND langbez.languageid = -1
	AND Daten.Datum = DatenLS.Datum
	AND Daten.KdNr = DatenLS.KdNr
	AND Daten.ArtikelID = DatenLS.ArtikelID
	ORDER BY Daten.Datum ASC;