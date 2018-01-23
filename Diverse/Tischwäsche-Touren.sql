TRY
	DROP TABLE #TmpVsaTour;
	DROP TABLE #TmpKdBerID;
CATCH ALL END;

SELECT VsaTour.*, (SELECT MAX(VsaTour.ID) FROM VsaTour) AS MaxID, ROWNUM() AS NewID, Vsa.KundenID
INTO #TmpVsaTour
FROM VsaTour, KdBer, Bereich, Vsa
WHERE VsaTour.KdBerID = KdBer.ID
	AND KdBer.BereichID = Bereich.ID
	AND Bereich.Bereich = 'SH'
	AND VsaTour.VsaID = Vsa.ID
	AND Vsa.KundenID IN (
 		SELECT Kunden.ID
		FROM Kunden, KdBer, Bereich
		WHERE KdBer.KundenID = Kunden.ID
		  AND KdBer.BereichID = Bereich.ID
		  AND Bereich.Bereich = 'TW'
	)
	AND VsaTour.VsaID NOT IN (
		SELECT VsaTour.VsaID
		FROM VsaTour, KdBer, Bereich
		WHERE VsaTour.KdBerID = KdBer.ID
			AND KdBer.BereichID = Bereich.ID
			AND Bereich.Bereich = 'TW'
	);

UPDATE #TmpVsaTour SET ID = MaxID + NewID;

SELECT KdBer.ID, KdBer.KundenID
INTO #TmpKdBerID
FROM KdBer, Bereich
WHERE KdBer.BereichID = Bereich.ID
	AND Bereich.Bereich = 'TW';
	
UPDATE vt SET vt.KdBerID = kdi.ID
FROM #TmpVsaTour vt, #TmpKdBerID kdi
WHERE vt.KundenID = kdi.KundenID;

UPDATE #TmpVsaTour SET Anlage_ = NOW(), Update_ = NOW(), AnlageUser_ = 'STHA', User_ = 'STHA';

INSERT INTO VsaTour
SELECT ID, VsaID, TourenID, KdBerID, Folge, Holen, Bringen, LiefVsaTourID, StopZeit, AusliefDauer, AvgMenge, Ankunftszeit, Anlage_, Update_, User_, AnlageUser_
FROM #TmpVsaTour;