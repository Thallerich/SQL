SELECT Kunden.ID AS KundenID, Kunden.Name1, Kunden.Name2, Kunden.Name3, Kunden.Strasse, Kunden.PLZ, Kunden.Ort, Kunden.UStIDNr, RechKo.Art, RechKo.RechNr, RechKo.FaelligDat, RechKo.RechDat, RechKo.MwStBetrag, RechKo.BruttoWert, Firma.Bez FirmaBez, RTRIM(Abteil.Abteilung) + ' ' + RTRIM(Abteil.Bez) AS Kostenstelle, ZahlZiel.ZahlZielBez$LAN$ AS Zahlungsziel, RechPo.GPreis AS BetragKostenstelle
FROM Kunden, Abteil, Firma, RechKo, RechPo, ZahlZiel
WHERE Kunden.ZahlZielID  = ZahlZiel.ID
	AND Kunden.FirmaID = Firma.ID
	AND RechKo.KundenID = Kunden.ID
	AND RechPo.RechKoID = RechKo.ID
	AND RechPo.AbteilID = Abteil.ID
	AND RechKo.ID = $RECHKOID$
ORDER BY Kostenstelle;