DROP TABLE IF EXISTS #LsStandort;

SELECT LsKo.ID LsKoID, LsKo.FahrtID, LsPo.ID LsPoID, LsKo.VsaID, LsPo.ProduktionID, Fahrt.ExpeditionID, KdBer.BereichID, Fahrt.ExpeditionID newExpeditionID,  LsPo.ProduktionID newProduktionID
INTO #LsStandort
FROM lsko, LsPo, Fahrt, KdArti, KDBer, Vsa
WHERE Lsko.senttosap = 0
  AND LsKo.Status >= 'Q'
  AND LsPo.LskoID = LsKo.ID
  AND LsKo.FahrtID = Fahrt.ID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.KdBerID = KdBer.ID
  AND LsKo.VsaID = Vsa.ID
  AND (Fahrt.ExpeditionID = -1 OR LsPo.ProduktionID = -1);

UPDATE #LsStandort SET newExpeditionID = StandBer.ExpeditionID
FROM StandBer, Vsa
WHERE Vsa.ID = #LsStandort.VsaID
  AND StandBer.StandKonID = Vsa.StandKonID
  AND StandBer.BereichID = #LsStandort.BereichID
  AND #LsStandort.ExpeditionID = -1;

UPDATE #LsStandort SET newProduktionID = StandBer.ProduktionID
FROM StandBer, Vsa
WHERE Vsa.ID = #LsStandort.VsaID
  AND StandBer.StandKonID = Vsa.StandKonID
  AND StandBer.BereichID = #LsStandort.BereichID
  AND #LsStandort.ExpeditionID = -1;

UPDATE #LsStandort SET newProduktionID = Kunden.StandortID
FROM Kunden, VSA
WHERE #LsStandort.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND #LsStandort.newProduktionID = -1;
 
UPDATE #LsStandort SET newExpeditionID = Kunden.StandortID
FROM Kunden, VSA
WHERE #LsStandort.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND #LsStandort.newExpeditionID = -1;

UPDATE LsPo SET ProduktionID = newProduktionID
FROM #LsStandort
WHERE #LsStandort.LsPoID = LsPo.ID
  AND  LsPo.ProduktionID <> newProduktionID;
 
UPDATE Fahrt SET ExpeditionID = newExpeditionID
FROM #LsStandort
WHERE #LsStandort.FahrtID = Fahrt.ID
  AND Fahrt.ID > 0
  AND Fahrt.ExpeditionID <> newExpeditionID;
 
INSERT INTO Fahrt (PlanDatum, UrDatum, TourenID, FahrzeugID, MitarbeiID, ExpeditionID, AnlageUserID_)
SELECT DISTINCT LsKo.Datum, LsKo.Datum, LsKo.TourenID, Touren.FahrzeugID, Touren.MitarbeiID, newExpeditionID, 8888
FROM #LsStandort, LsKo, Touren
WHERE LsKo.ID = #LsStandort.LskoID
  AND LsKo.TourenID = Touren.ID
  AND #LsStandort.FahrtID = -1;

UPDATE LsKo SET FahrtID = Fahrt.ID
FROM #LsStandort, Fahrt
WHERE LsKo.ID = #LsStandort.LskoID
  AND LsKo.FahrtID = -1
  AND Fahrt.PlanDatum = LsKo.Datum
  AND Fahrt.TourenID = LsKo.TourenID
  AND Fahrt.AnlageUserID_ = 8888;