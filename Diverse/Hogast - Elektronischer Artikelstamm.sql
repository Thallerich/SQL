SELECT '0989' AS EMPFAENGER_NR, '9006140000000' AS EMPFAENGER_GLN, '4331' AS LFNR, 'J' AS LISTUNGS_KZ, Artikel.ArtikelNr AS ARTNR, '' AS EAN, '' AS EAN_PRSEH, Langbez.Bez AS ARTBEZ1, '' AS ARTBEZ2, ProdHier.Bez AS ARTGRP, MwSt.MwStSatz AS MWST, ME.ME AS LFEH, '' AS PRSEH, '' AS FAKTOR, CURDATE() AS GUELTIGVON, '' AS GUELTIGBIS, '' AS STAFFEL, '' AS PEH, IIF(KdArti.WaschPreis = 0, KdArti.LeasingPreis, KdArti.WaschPreis) AS PREIS, 'N' AS AKTIONSPREIS, 'N' AS PREISMODUS, 'DI' AS PREISTYP, TRIM(SUBSTRING(RechAdr.Name3,LOCATE(':', RechAdr.Name3,1)+1,5)) AS MGNUMMER, '' AS EKGRUPPE, '' AS PLZ_VON, '' AS PLZ_BIS, '' AS ARTNRTAUSCH, '' AS BILDNAME, '' AS BILDPFAD
FROM Holding, Kunden, Artikel, Langbez, ProdHier, MwSt, ME, PrArchiv, RechAdr, KdArti, Abteil, Vsa
WHERE Kunden.HoldingID = Holding.ID
	AND Holding.Holding = 'HOGAST'
	AND KdArti.KundenID = Kunden.ID
	AND KdArti.ArtikelID = Artikel.ID
	AND LangBez.TableID = Artikel.ID
	AND LangBez.TableName = 'ARTIKEL'
	AND Artikel.ProdHierID = ProdHier.ID
	AND Artikel.MEID = ME.ID
	AND Kunden.MwStID = MwSt.ID
	AND Abteil.KundenID = Kunden.ID
	AND Abteil.RechAdrID = RechAdr.ID
	AND PrArchiv.KdArtiID = KdArti.ID
	AND PrArchiv.Datum >= $1$
	AND Vsa.AbteilID = Abteil.ID
	AND Vsa.Status = 'A'
GROUP BY ARTNR, ARTBEZ1, ARTGRP, MWST, LFEH, PREIS, MGNUMMER