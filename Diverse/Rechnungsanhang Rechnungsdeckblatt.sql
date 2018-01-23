Reportdatei: Shared\Rechnungsdeckblatt.rtm

--RKo.ID = 10637559

--Kopf-Fuss

SELECT NettoWert as EURSumme, MWStBetrag as MWST, BruttoWert as Brutto, Kunden.UStIdNr, KdNr, Kunden.Name1, Kunden.Name2, Kunden.Name3, Kunden.Strasse, Kunden.PLZ, Kunden.Ort, RKo.RechDat, RKo.RechNr, RKo.VonDatum, RKo.BisDatum, ValutaDat, (MONTH(ValutaDat)-1) as Monat, CASE RKo.Art WHEN 'R' THEN 'Rechnung' ELSE 'Gutschrift' END as Art, Firma.Footer, ZahlZiel.Bez ZahlZielBez, Firma.Absender

FROM Kunden, RKo, Firma, ZahlZiel

WHERE Kunden.ZahlZielID=ZahlZiel.ID and Firma.ID=Kunden.FirmaID and RKo.KundenID=Kunden.ID and RKo.ID=10637559

--Kostenstellen - 26 Datensätze

SELECT SUM(RPo.GPreis) as EURSumme, Abteil.Bez, Kunden.UStIdNr, KdNr, Kunden.Name1, Kunden.Name2, Kunden.Name3, Kunden.Strasse, Kunden.PLZ, Kunden.Ort, RKo.RechDat, RKo.RechNr, RKo.VonDatum, RKo.BisDatum, ValutaDat 

FROM Kunden, RKo, RPo, Abteil
WHERE Abteil.ID=RPo.AbteilID and RPo.RKoID=RKo.ID and RKo.KundenID=Kunden.ID and RKo.ID=10637559

GROUP BY Abteil.Bez, KdNr, Kunden.Name1, Kunden.Name2, Kunden.Name3, Kunden.Strasse, Kunden.PLZ, Kunden.Ort, RKo.RechDat, RKo.RechNr, RKo.VonDatum, RKo.BisDatum, ValutaDat, Kunden.UStIdNr


-- Rechnungsdeckblatt neu - druckbar --

-- Datenfelder im Report:
Kunden.Name1
Kunden.Name2
Kunden.Name3
Kunden.Strasse
Kunden.PLZ
Kunden.Ort
RKo.Art
RKo.RechNr
RKo.ValutaDat
RKo.RechDat
Firma.Absender
Kunden.UStIDNr
Abteil.Bez
SUM(RPo.GPreis) -- Summe je Kostenstelle
RKo.MwStBetrag
RKo.BruttoWert
ZahlZiel.Bez
Firma.Footer

#################################################################################################################################################

SELECT Kunden.Name1, Kunden.Name2, Kunden.Name3, Kunden.Strasse, Kunden.PLZ, Kunden.Ort, Kunden.UStIDNr, RKo.Art, RKo.RechNr, RKo.ValutaDat, RKo.RechDat, RKo.MwStBetrag, RKo.BruttoWert, Firma.Absender, Firma.Footer, Abteil.Bez AS Kostenstelle, ZahlZiel.Bez AS Zahlungsziel, SUM(RPo.GPreis) AS SummeKostenStelle
FROM Kunden, Abteil, Firma, RKo, Rpo, ZahlZiel
WHERE Kunden.ZahlZielID  = ZahlZiel.ID
	AND Kunden.FirmaID = Firma.ID
	AND RKo.KundenID = Kunden.ID
	AND RPo.RKoID = RKo.ID
	AND RPo.AbteilID = Abteil.ID
	AND RKo.ID = 10637559
GROUP BY Kunden.Name1, Kunden.Name2, Kunden.Name3, Kunden.Strasse, Kunden.PLZ, Kunden.Ort, Kunden.UStIDNr, RKo.Art, RKo.RechNr, RKo.ValutaDat, RKo.RechDat, RKo.MwStBetrag, RKo.BruttoWert, Firma.Absender, Firma.Footer, Kostenstelle, Zahlungsziel

#################################################################################################################################################

SELECT Kunden.Name1, Kunden.Name2, Kunden.Name3, Kunden.Strasse, Kunden.PLZ, Kunden.Ort, Kunden.UStIDNr, RKo.Art, RKo.RechNr, RKo.ValutaDat, RKo.RechDat, RKo.MwStBetrag, RKo.BruttoWert, Firma.Absender, Firma.Footer, Abteil.Bez AS Kostenstelle, ZahlZiel.Bez AS Zahlungsziel, RPo.GPreis AS BetragKostenStelle
FROM Kunden, Abteil, Firma, RKo, Rpo, ZahlZiel
WHERE Kunden.ZahlZielID  = ZahlZiel.ID
	AND Kunden.FirmaID = Firma.ID
	AND RKo.KundenID = Kunden.ID
	AND RPo.RKoID = RKo.ID
	AND RPo.AbteilID = Abteil.ID
	AND RKo.ID = 10637559
--GROUP BY Kunden.Name1, Kunden.Name2, Kunden.Name3, Kunden.Strasse, Kunden.PLZ, Kunden.Ort, Kunden.UStIDNr, RKo.Art, RKo.RechNr, RKo.ValutaDat, RKo.RechDat, RKo.MwStBetrag, RKo.BruttoWert, Firma.Absender, Firma.Footer, Kostenstelle, Zahlungsziel