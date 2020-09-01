DECLARE @bisDatum date = EOMONTH(GETDATE(), -1);
DECLARE @vonDatum date = DATEADD(day, 1, EOMONTH(GETDATE(), -2));

-- leere Lieferscheine bzgl. SAP-Übergabe erledigen
UPDATE LsKo SET InternKalkFix = 1, SentToSAP = -1
WHERE LsKo.Status >= N'Q'
  AND LsKo.Datum BETWEEN @vonDatum AND @bisDatum
  AND NOT EXISTS (
    SELECT LsPo.ID
    FROM LsPo
    WHERE LsPo.LsKoID = LsKo.ID
      AND  LsPo.Menge != 0)
  AND (LsKo.SentToSAP = 0 OR LsKo.InternKalkFix = 0);

-- Lieferscheine/Waschlöhne von internen Kunden bzgl. SAP-Übergabe erledigen
UPDATE LsKo SET InternKalkFix = 1, SentToSAP = -1
FROM LsKo
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE LsKo.Status >= N'Q'
  AND LsKo.Datum BETWEEN @vonDatum AND @bisDatum
  AND (LsKo.SentToSAP = 0 OR LsKo.InternKalkFix = 0)
  AND Kunden.KdGfID NOT IN (
    SELECT KdGf.ID 
    FROM KdGf 
    WHERE KdGf.KurzBez IN (N'MED', N'GAST', N'JOB', N'SAEU')
  );

DROP TABLE IF EXISTS #LsStandort;

SELECT LsKo.ID AS LsKoID, LsKo.FahrtID, LsPo.ID AS LsPoID, LsKo.VsaID, LsPo.ProduktionID, Fahrt.ExpeditionID, KdBer.BereichID, Fahrt.ExpeditionID AS newExpeditionID, LsPo.ProduktionID AS newProduktionID
INTO #LsStandort
FROM Lsko
JOIN LsPo ON LsPo.LsKoID = LsKo.ID
JOIN Fahrt ON LsKo.FahrtID = Fahrt.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN KDBer ON KdArti.KdBerID = KdBer.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
WHERE Lsko.SentToSAP = 0
  AND LsKo.InternKalkFix = 0 
  AND LsKo.Status >= N'Q'
  AND LsKo.Datum BETWEEN @vonDatum AND @bisDatum
  AND (Fahrt.ExpeditionID = -1 OR LsPo.ProduktionID = -1);

UPDATE #LsStandort SET newExpeditionID = StandBer.ExpeditionID
FROM StandBer
JOIN Vsa ON Vsa.StandKonID = StandBer.StandKonID
WHERE Vsa.ID = #LsStandort.VsaID
  AND StandBer.BereichID = #LsStandort.BereichID
  AND #LsStandort.ExpeditionID = -1;

UPDATE #LsStandort SET newProduktionID = StandBer.ProduktionID
FROM StandBer
JOIN Vsa ON Vsa.StandKonID = StandBer.StandKonID
WHERE Vsa.ID = #LsStandort.VsaID
  AND StandBer.BereichID = #LsStandort.BereichID
  AND #LsStandort.ExpeditionID = -1;

UPDATE #LsStandort SET newProduktionID = Kunden.StandortID
FROM Kunden
JOIN Vsa ON Vsa.KundenID = Kunden.ID
WHERE #LsStandort.VsaID = Vsa.ID
  AND #LsStandort.newProduktionID = -1;
 
UPDATE #LsStandort SET newExpeditionID = Kunden.StandortID
FROM Kunden
JOIN Vsa ON Vsa.KundenID = Kunden.ID
WHERE #LsStandort.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND #LsStandort.newExpeditionID = -1;

UPDATE LsPo SET ProduktionID = newProduktionID
FROM #LsStandort
WHERE #LsStandort.LsPoID = LsPo.ID
 AND LsPo.ProduktionID <> newProduktionID;
 
UPDATE Fahrt SET ExpeditionID = newExpeditionID
FROM #LsStandort
WHERE #LsStandort.FahrtID = Fahrt.ID
  AND Fahrt.ID > 0
  AND Fahrt.ExpeditionID <> newExpeditionID;
 
INSERT INTO Fahrt (PlanDatum, UrDatum, TourenID, ExpeditionID, AnlageUserID_)
SELECT DISTINCT LsKo.Datum, LsKo.Datum, LsKo.TourenID, newExpeditionID, 8888
FROM #LsStandort
JOIN LsKo ON LsKo.ID = #LsStandort.LsKoID
WHERE #LsStandort.FahrtID = -1;

UPDATE LsKo SET FahrtID = Fahrt.ID
FROM #LsStandort, Fahrt
WHERE LsKo.ID = #LsStandort.LskoID
  AND LsKo.FahrtID = -1
  AND Fahrt.PlanDatum = LsKo.Datum
  AND Fahrt.TourenID = LsKo.TourenID
  AND Fahrt.AnlageUserID_ = 8888;

DROP TABLE IF EXISTS #LsStandort;


/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++                                                                                                                           ++ */
/* ++      RUN;INKALKAPPLY                                                                                                      ++ */
/* ++                                                                                                                           ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @bisDatum date = EOMONTH(GETDATE(), -1);
DECLARE @vonDatum date = DATEADD(day, 1, EOMONTH(GETDATE(), -2));

SELECT @vonDatum, @bisDatum;

UPDATE LsKo SET InternKalkFix = 1
FROM LsKo
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE LsKo.Datum BETWEEN @vonDatum AND @bisDatum
  AND LsKo.Status >= N'Q'
  AND LsKo.SentToSAP = 0
  AND LsKo.InternKalkFix = 0
  AND Kunden.KdGfID IN (
    SELECT KdGf.ID
    FROM KdGf
    WHERE KdGf.KurzBez IN (N'MED', N'GAST', N'JOB', N'SAEU')
  )
  AND Kunden.FirmaID IN (
    SELECT Firma.ID
    FROM Firma
    WHERE Suchcode IN (N'FA14', N'WOMI', N'UKLU')
  );

DROP TABLE IF EXISTS __LsInKalk;

SELECT LsKo.ID, LsKo.Datum
INTO __LsInKalk
FROM LsKo
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE LsKo.Status >= N'Q'
  AND LsKo.SentToSAP = 0 
  AND LsKo.InternKalkFix = 1
  AND LsKo.Datum BETWEEN @vonDatum AND @bisDatum
  AND Kunden.KdGfID IN (
    SELECT KdGf.ID
    FROM KdGf
    WHERE KdGf.KurzBez IN (N'MED', N'GAST', N'JOB', N'SAEU')
  )
  AND Kunden.FirmaID IN (
    SELECT Firma.ID
    FROM Firma
    WHERE Suchcode IN (N'FA14', N'WOMI', N'UKLU')
  );