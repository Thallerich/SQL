-- Pipeline: KopfFuss
SELECT NettoWert AS EURSumme, MwStBetrag AS MWST, BruttoWert AS Brutto, Kunden.UStIdNr, Kunden.KdNr, Kunden.Name1, Kunden.Name2, Kunden.Name3, Kunden.Strasse, Kunden.PLZ, Kunden.Ort, RechKo.RechDat, RechKo.RechNr, RechKo.VonDatum, RechKo.BisDatum, FaelligDat, (MONTH(FaelligDat)-1) AS Monat, CASE RechKo.Art WHEN N'R' THEN N'Rechnung' ELSE N'Gutschrift' END AS Art, ZahlZiel.ZahlZielBez$LAN$ AS ZahlZielBez, Wae.Format
FROM Kunden, RechKo, ZahlZiel, Wae
WHERE Kunden.ZahlZielID = ZahlZiel.ID 
  AND RechKo.KundenID = Kunden.ID 
  AND Kunden.RechWaeID = Wae.ID
  AND RechKo.ID = $ID$;

-- Pipeline: Kostenstellen
SELECT SUM(RechPo.GPreis) AS EURSumme, Abteil.Bez, Kunden.UStIdNr, Kunden.KdNr, Kunden.Name1, Kunden.Name2, Kunden.Name3, Kunden.Strasse, Kunden.PLZ, Kunden.Ort, RechKo.RechDat, RechKo.RechNr, RechKo.VonDatum, RechKo.BisDatum, RechKo.FaelligDat, Wae.Format
FROM Kunden, RechKo, RechPo, Abteil, Wae
WHERE Abteil.ID = RechPo.AbteilID 
  AND RechPo.RechKoID = RechKo.ID 
  AND RechKo.KundenID = Kunden.ID 
  AND Kunden.RechWaeID = Wae.ID
  AND RechKo.ID = $ID$
GROUP BY Abteil.Bez, Kunden.KdNr, Kunden.Name1, Kunden.Name2, Kunden.Name3, Kunden.Strasse, Kunden.PLZ, Kunden.Ort, RechKo.RechDat, RechKo.RechNr, RechKo.VonDatum, RechKo.BisDatum, RechKo.FaelligDat, Kunden.UStIdNr, Wae.Format;