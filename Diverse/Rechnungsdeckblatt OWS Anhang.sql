--Kopf/Fuﬂ

SELECT NettoWert AS EURSumme, MWStBetrag AS MWST, BruttoWert AS Brutto, Kunden.UStIdNr, KdNr, Kunden.Name1, Kunden.Name2, Kunden.Name3, Kunden.StrASse, Kunden.PLZ, Kunden.Ort, RKo.RechDat, RKo.RechNr, RKo.VonDatum, RKo.BisDatum, ValutaDat, (MONTH(ValutaDat)-1) AS Monat, IF (RKo.Art = 'R', 'Rechnung', 'Gutschrift') AS Art, Firma.Footer, ZahlZiel.Bez ZahlZielBez, Firma.Absender
FROM Kunden, RKo, Firma, ZahlZiel
WHERE Kunden.ZahlZielID = ZahlZiel.ID 
	AND Firma.ID = Kunden.FirmaID 
	AND RKo.KundenID = Kunden.ID 
	AND RKo.ID = $ID$;

--Kostenstellen

SELECT SUM(RPo.GPreis) AS EURSumme, Abteil.Bez, Kunden.UStIdNr, KdNr, Kunden.Name1, Kunden.Name2, Kunden.Name3, Kunden.Strasse, Kunden.PLZ, Kunden.Ort, RKo.RechDat, RKo.RechNr, RKo.VonDatum, RKo.BisDatum, ValutaDat, Abteil.Abteilung 
FROM Kunden, RKo, RPo, Abteil
WHERE Abteil.ID = RPo.AbteilID 
	AND RPo.RKoID = RKo.ID 
	AND RKo.KundenID = Kunden.ID 
	AND RKo.ID = $ID$
GROUP BY 2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
ORDER BY Abteil.Abteilung;