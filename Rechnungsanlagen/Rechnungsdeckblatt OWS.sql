SELECT SUM(RechPo.GPreis) AS EURSumme, Abteil.Bez, Kunden.UStIdNr, Kunden.KdNr, Kunden.Name1, Kunden.Name2, Kunden.Name3, Kunden.Strasse, Kunden.PLZ, Kunden.Ort, RechKo.RechDat, RechKo.RechNr, RechKo.VonDatum, RechKo.BisDatum, RechKo.FaelligDat, Abteil.Abteilung
FROM Kunden, RechKo, RechPo, Abteil
WHERE Abteil.ID = RechPo.AbteilID
	AND RechPo.RechKoID = RechKo.ID
	AND RechKo.KundenID = Kunden.ID
	AND RechKo.ID = $RECHKOID$
GROUP BY Abteil.Bez, Kunden.UStIdNr, Kunden.KdNr, Kunden.Name1, Kunden.Name2, Kunden.Name3, Kunden.Strasse, Kunden.PLZ, Kunden.Ort, RechKo.RechDat, RechKo.RechNr, RechKo.VonDatum, RechKo.BisDatum, RechKo.FaelligDat, Abteil.Abteilung
ORDER BY Abteil.Abteilung;