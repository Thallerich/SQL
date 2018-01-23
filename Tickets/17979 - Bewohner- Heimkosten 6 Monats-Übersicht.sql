TRY
	DROP TABLE #TmpDataBewHeim;
	DROP TABLE #TmpBewHeim6;
CATCH ALL
END TRY;

SELECT TIMESTAMPDIFF(SQL_TSI_MONTH, RKo.RechDat, $1$) AS MonatOrder, abteil.Abteilung, abteil.Bez as KoStBez, abteil.id AS KoStID, traeger.Nachname, traeger.Vorname, traeger.ID TraegerID, traeger.PersNr AS ZimmerNr, Traeger.Traeger, BewAbr.ServiceProz, KdBer.RabattWasch, ROUND(SUM(LsPo.Menge*LsPo.EPreis),2) AS NettoPreis, ROUND(SUM(LsPo.Menge*LsPo.EPreis*(1-(KdBer.RabattWasch/100)) *  ProzTraeger/100 * (1+(RKo.MwStSatz/100))), 2) AS BruttoTraeger, ROUND(SUM(LsPo.Menge*LsPo.EPreis*(1-(KdBer.RabattWasch/100)) * (1-(ProzTraeger/100)) * (1+(RKo.MwStSatz/100))), 2) AS BruttoHeim
INTO #TmpDataBewHeim
FROM LsPo, LsKo, Traeger, rpo, rko, abteil, bewkdar, bewabr, KdArti, KdBer
WHERE LsKo.ID = LsPo.LsKoID
	AND LsPo.RPoID = rpo.ID 
	AND rpo.RKoID IN (
		SELECT RKo.ID
		FROM RKo, Kunden
		WHERE RKo.KundenID = Kunden.ID
			AND Kunden.ID = $ID$
			AND TIMESTAMPDIFF(SQL_TSI_MONTH, RKo.RechDat, $1$)  < 6  -- 6 Monate
			AND RKo.RechDat <= $1$
	)
	AND Abteil.ID = RPo.AbteilID 
	AND Traeger.ID = LsKo.TraegerID 
	AND LsKo.TraegerID <> -1 
	AND Traeger.BewAbrID = bewkdar.bewabrID 
	AND BewAbr.ID = Traeger.BewAbrID 
	AND bewkdar.kdartiid = lspo.kdartiid 
	AND rpo.rkoid = rko.id 
	AND KdBer.ID = KdArti.KdBerID 
	AND KdArti.ID = LsPo.KdArtiID
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11;

SELECT Abteilung, KoStBez, KoStID, Nachname, Vorname, TraegerID, ZimmerNr, Traeger, ServiceProz, RabattWasch, CONVERT(0, SQL_MONEY) AS Traeger1, CONVERT(0, SQL_MONEY) AS Heim1, CONVERT(0, SQL_MONEY) AS Traeger2, CONVERT(0, SQL_MONEY) AS Heim2, CONVERT(0, SQL_MONEY) AS Traeger3, CONVERT(0, SQL_MONEY) AS Heim3, CONVERT(0, SQL_MONEY) AS Traeger4, CONVERT(0, SQL_MONEY) AS Heim4, CONVERT(0, SQL_MONEY) AS Traeger5, CONVERT(0, SQL_MONEY) AS Heim5, CONVERT(0, SQL_MONEY) AS Traeger6, CONVERT(0, SQL_MONEY) AS Heim6, CONVERT(0, SQL_MONEY) AS TraegerSumme, CONVERT(0, SQL_MONEY) AS HeimSumme
INTO #TmpBewHeim6
FROM #TmpDataBewHeim
GROUP BY Abteilung, KoStBez, KoStID, Nachname, Vorname, TraegerID, ZimmerNr, Traeger, ServiceProz, RabattWasch;

UPDATE BW6 
SET Traeger1 = DBW.BruttoTraeger, Heim1 = DBW.BruttoHeim
FROM #TmpBewHeim6 BW6, #TmpDataBewHeim DBW
WHERE BW6.TraegerID = DBW.TraegerID
	AND DBW.MonatOrder = 5
	AND BW6.KoStID = DBW.KoStID;
	
UPDATE BW6
SET Traeger2 = DBW.BruttoTraeger, Heim2 = DBW.BruttoHeim
FROM #TmpBewHeim6 BW6, #TmpDataBewHeim DBW
WHERE BW6.TraegerID = DBW.TraegerID
	AND DBW.MonatOrder = 4
	AND BW6.KoStID = DBW.KoStID;

UPDATE BW6
SET Traeger3 = DBW.BruttoTraeger, Heim3 = DBW.BruttoHeim
FROM #TmpBewHeim6 BW6, #TmpDataBewHeim DBW
WHERE BW6.TraegerID = DBW.TraegerID
	AND DBW.MonatOrder = 3
	AND BW6.KoStID = DBW.KoStID;

UPDATE BW6
SET Traeger4 = DBW.BruttoTraeger, Heim4 = DBW.BruttoHeim
FROM #TmpBewHeim6 BW6, #TmpDataBewHeim DBW
WHERE BW6.TraegerID = DBW.TraegerID
	AND DBW.MonatOrder = 2
	AND BW6.KoStID = DBW.KoStID;
	
UPDATE BW6
SET Traeger5 = DBW.BruttoTraeger, Heim5 = DBW.BruttoHeim
FROM #TmpBewHeim6 BW6, #TmpDataBewHeim DBW
WHERE BW6.TraegerID = DBW.TraegerID
	AND DBW.MonatOrder = 1
	AND BW6.KoStID = DBW.KoStID;
	
UPDATE BW6
SET Traeger6 = DBW.BruttoTraeger, Heim6 = DBW.BruttoHeim
FROM #TmpBewHeim6 BW6, #TmpDataBewHeim DBW
WHERE BW6.TraegerID = DBW.TraegerID
	AND DBW.MonatOrder = 0
	AND BW6.KoStID = DBW.KoStID;
	
UPDATE BW6
SET TraegerSumme = Traeger1 + Traeger2 + Traeger3 + Traeger4 + Traeger5 + Traeger6, HeimSumme = Heim1 + Heim2 + Heim3 + Heim4 + Heim5 + Heim6
FROM #TmpBewHeim6 BW6;

SELECT *
FROM #TmpBewHeim6;