SELECT Kunden.ID AS KundenID, Kunden.UStIDNr, Vsa.Bez AS VsaBez, RechKo.Art, RechKo.RechNr, RechKo.FaelligDat, RechKo.RechDat, RechKo.MwStBetrag, RechKo.BruttoWert, ZahlZiel.ZahlZielBez$LAN$ AS Zahlungsziel, SUM(RechPo.GPreis) AS Betrag
FROM Kunden, RechKo, RechPo, ZahlZiel, Vsa
WHERE Kunden.ZahlZielID  = ZahlZiel.ID
  AND RechKo.KundenID = Kunden.ID
  AND RechPo.RechKoID = RechKo.ID
  AND RechPo.VsaID = Vsa.ID
  AND RechKo.ID = $RECHKOID$
GROUP BY Kunden.ID, Kunden.UStIDNr, Vsa.Bez, RechKo.Art, RechKo.RechNr, RechKo.FaelligDat, RechKo.RechDat, RechKo.MwStBetrag, RechKo.BruttoWert, ZahlZiel.ZahlZielBez$LAN$
ORDER BY Vsa.Bez;