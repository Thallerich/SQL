SELECT DISTINCT Kunden.ID AS KundenID, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.ID AS VsaID, Vsa.VsaNr, Vsa.Bez AS VsaBezeichnung, RechKo.RechNr, RechKo.NettoWert, RechKo.MwStBetrag, RechKo.BruttoWert, Touren.Tour, Fahrt.ID AS FahrtID, Fahrt.PlanDatum AS Fahrtdatum, Expedition.SuchCode AS Expedition
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN RechPo ON LsPo.RechPoID = RechPo.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Fahrt ON LsKo.FahrtID = Fahrt.ID
JOIN Touren ON Fahrt.TourenID = Touren.ID
JOIN Standort AS Expedition ON Fahrt.ExpeditionID = Expedition.ID
WHERE Kunden.BarRech = 1 
  AND LsPo.RechPoID > 0
  AND Fahrt.PlanDatum BETWEEN $2$ AND $3$
  AND Expedition.ID = $1$
ORDER BY Expedition, Tour, Kunden.KdNr