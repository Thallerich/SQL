SET XACT_ABORT ON;
SET NOCOUNT ON;
GO

DROP TABLE IF EXISTS #LsStandort;
GO

-- leere Lieferscheine bzgl. SAP-Übergabe erledigen
UPDATE LsKo SET InternKalkFix = 1, SentToSAP = -1
WHERE LsKo.Status >= 'Q'
  AND NOT EXISTS (SELECT LsPo.ID FROM LsPo WHERE LsPo.LsKoID = LsKo.ID AND  LsPo.Menge <> 0)
  AND (LsKo.SentToSAP = 0 OR LsKo.InternKalkFix = 0)
  AND LsKo.Datum < CAST(GETDATE() AS date);

GO

-- Lieferscheine/Waschlöhne von internen Kunden bzgl. SAP-Übergabe erledigen
UPDATE LsKo SET InternKalkFix = 1, SentToSAP = -1
FROM vsa, kunden
WHERE lsko.VsaID = vsa.id
  AND vsa.kundenid = kunden.id
  AND LsKo.Status >= 'Q'
  AND (LsKo.SentToSAP = 0 OR LsKo.InternKalkFix = 0)
  AND kunden.KdGfID NOT IN (SELECT ID FROM KdGf WHERE KurzBez IN (N'MED', N'GAST', N'JOB', N'SAEU', N'BM', N'RT', N'MIC'));

GO

-- Rechnungen von internen Kunden bzgl. SAP-Übergabe erledigen
UPDATE RechKo SET FiBuExpID = -2
FROM Kunden
WHERE RechKo.kundenID = Kunden.ID
  AND RechKo.FiBuExpID = -1
  AND RechKo.Status >= 'F'
  AND kunden.KdGfID NOT IN (SELECT ID FROM KdGf WHERE KurzBez IN (N'MED', N'GAST', N'JOB', N'SAEU', N'BM', N'RT', N'MIC'));

GO

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

GO

UPDATE LsPo SET ProduktionID = newProduktionID
FROM #LsStandort
WHERE #LsStandort.LsPoID = LsPo.ID
  AND LsPo.ProduktionID <> newProduktionID;

GO
 
UPDATE Fahrt SET ExpeditionID = newExpeditionID
FROM #LsStandort
WHERE #LsStandort.FahrtID = Fahrt.ID
  AND Fahrt.ID > 0
  AND Fahrt.ExpeditionID <> newExpeditionID;

GO
 
INSERT INTO Fahrt (PlanDatum, UrDatum, TourenID, ExpeditionID, AnlageUserID_)
SELECT DISTINCT LsKo.Datum, LsKo.Datum, LsKo.TourenID, newExpeditionID, 8888
FROM #LsStandort, LsKo
WHERE LsKo.ID = #LsStandort.LskoID
  AND #LsStandort.FahrtID = -1;


GO

UPDATE LsKo SET FahrtID = Fahrt.ID
FROM #LsStandort, Fahrt
WHERE LsKo.ID = #LsStandort.LskoID
  AND LsKo.FahrtID = -1
  AND Fahrt.PlanDatum = LsKo.Datum
  AND Fahrt.TourenID = LsKo.TourenID
  AND Fahrt.AnlageUserID_ = 8888;

GO

SELECT N'INKALKAPPLY;' + FORMAT(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0), N'yyyyMMdd') + ';' + FORMAT(EOMONTH(GETDATE(), -1), N'yyyyMMdd') AS ModuleCall
UNION
SELECT N'INKALKFIX;' + FORMAT(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0), N'yyyyMMdd') + ';' + FORMAT(EOMONTH(GETDATE(), -1), N'yyyyMMdd') AS ModuleCall

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

IF OBJECT_ID(N'__LsInKalk') IS NOT NULL
  TRUNCATE TABLE __LsInKalk;
ELSE
  CREATE TABLE __LsInKalk (
    ID int
  );

DECLARE @LsKo TABLE (
  ID int PRIMARY KEY,
  [Status] nchar(1),
  VsaID int
);

INSERT INTO @LsKo (ID, [Status], VsaID)
SELECT LsKo.ID, LsKo.[Status], LsKo.VsaID
FROM LsKo
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE LsKo.[Status] >= N'Q'
  AND LsKo.SentToSAP = 0
  AND LsKo.InternKalkFix = 1
  AND (LEFT(LsKo.Referenz, 7) != N'INTERN_' OR LsKo.Referenz IS NULL) /* Umlagerungs-LS ausnehmen, diese werden vom Modul SAPSENDSTOCKTRANSACTION übertragen */
  AND LsKo.Datum >= N'2025-04-01'
  AND LsKo.Datum < N'2025-07-01'
  AND Kunden.KdNr IN (10007589, 10007541, 10007385, 10007307, 10007544, 10007550, 10007543, 10007547, 10007545, 10007537, 10007439, 10007542, 10007440, 10007553, 10007643, 10007552, 10007589, 10007433, 10007548, 10007554, 10007549, 10007546, 10007268, 10007267, 217974, 10007394, 10007663, 10007411, 10007378, 10007379, 10007452, 10007435, 10007398, 10007309, 10007397, 216810, 10007420, 10007497, 10007401, 10007289, 10007418, 10007445, 10007443, 10007380, 10007381, 10007432, 10007402, 10007438, 10007396, 10007384, 10007392, 10007382, 10007383, 10007399, 10007400, 10007419, 10007444, 10007412, 10007268, 10007663, 10007626, 10007406, 10007407, 2312040, 2312150, 2302160, 10007473, 10007405, 2331284, 10007408, 2330246, 2312160, 10007302, 2302140, 2302120, 10007694, 2302130, 2302121, 10007409, 2302118, 2330131, 10007413, 10007410, 10007414, 10007416, 10007466, 10007424, 10007425, 10007415, 10007417, 10007403, 2520328, 10007393, 10007367, 10007421, 10007376, 10007427, 10007386, 10007372, 10007429, 10007437, 10007426, 10007395, 10007486, 10007363, 10007371, 10007366, 10007369, 10007387, 10007434, 10007428, 10007436, 10007391, 10007422, 10007431, 10007370, 10007388, 10007430, 10007368, 10007377);
;

INSERT INTO __LsInKalk (ID)
SELECT LsKo.ID
FROM @LsKo LsKo
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
WHERE (
    (Firma.SuchCode = N'FA14' AND KdGf.KurzBez IN (N'MED', N'GAST', N'JOB', N'SAEU', N'BM', N'RT', N'MIC'))
    OR
    (Firma.SuchCode IN (N'SMP', N'SMKR', N'SMSK', N'SMRO', N'BUDA', N'SMRS', N'SMSL',N'SMHR', N'SMPL'))
  );

GO

SELECT N'INKALKSEND;' + FORMAT(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0), N'yyyyMMdd') + ';' + FORMAT(EOMONTH(GETDATE(), -1), N'yyyyMMdd') + ';__LsInKalk' AS ModuleCall;
GO