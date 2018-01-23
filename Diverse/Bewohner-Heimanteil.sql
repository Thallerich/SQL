TRY
	DROP TABLE #TmpLsPoSum;
CATCH ALL END;

SELECT Abteil.Abteilung, Abteil.Bez AS KoStBez, Abteil.ID AS KoStID, Traeger.Nachname, Traeger.Vorname, Traeger.Traeger, Traeger.PersNr AS ZimmerNr, BewAbr.ServiceProz, KdBer.RabattWasch, BewKdAr.ProzTraeger, LsPo.ID, LsPo.Menge * LsPo.EPreis * (1 - (KdBer.RabattWasch/100)) AS PosSumme, LsPo.Menge * LsPo.EPreis * (1 - (KdBer.RabattWasch/100)) * ProzTraeger/100 AS AntBew, LsPo.Menge * LsPo.EPreis * (1 - (KdBer.RabattWasch/100)) * (1 - (ProzTraeger/100)) AS AntHeim, KdBer.BereichID
INTO #TmpLsPoSum
FROM LsPo, LsKo, RPo, RKo, Abteil, Traeger, BewAbr, KdBer, KdArti
LEFT OUTER JOIN BewKdAr ON (BewKdAr.BewAbrID = BewAbrID AND BewKdAr.KdArtiID = KdArti.ID)
WHERE LsPo.LsKoID = LsKo.ID
	AND LsPo.RPoID = RPo.ID
	AND RPo.RKoID = RKo.ID
	AND RKo.ID = $RKOID$
	AND LsPo.AbteilID = Abteil.ID
	AND LsKo.TraegerID = Traeger.ID
	AND Traeger.BewAbrID = BewAbr.ID
	AND LsPo.KdArtiID = KdArti.ID
	AND KdArti.KdBerID = KdBer.ID;

SELECT LPS.Abteilung, LPS.KoStBez, LPS.KoStID, LPS.Nachname, LPS.Vorname, LPS.ZimmerNr, LPS.Traeger, LPS.RabattWasch, LPS.ServiceProz, SUM(LPS.PosSumme) AS NettoPreis, SUM(LPS.PosSumme) * 1.2 AS BruttoPreis, SUM(LPS.AntBew) AS NettoTraeger, SUM(LPS.AntBew) * 1.2 AS BruttoTraeger, SUM(LPS.AntHeim) AS NettoHeim, SUM(LPS.AntHeim) * 1.2 AS BruttoHeim
FROM #TmpLsPoSum LPS, Bereich
WHERE LPS.BereichID = Bereich.ID
	AND Bereich.Bereich = 'CT'
GROUP BY LPS.Abteilung, LPS.KoStBez, LPS.KoStID, LPS.Nachname, LPS.Vorname, LPS.ZimmerNr, LPS.Traeger, LPS.RabattWasch, LPS.ServiceProz
ORDER BY Nachname, Vorname;