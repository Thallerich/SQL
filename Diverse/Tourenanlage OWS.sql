TRY
  DROP TABLE #TmpVsaTourW;
CATCH ALL END;

SELECT Vsa.ID AS VsaID, Vsa.VsaNr, Vsa.SuchCode, Vsa.Bez, '        ' AS Tour1, '        ' AS Tour2, '        ' AS Tour3, '        ' AS Tour4, '        ' AS Tour5, 0 AS Tour1UpdID, 0 AS Tour2UpdID, 0 AS Tour3UpdID, 0 AS Tour4UpdID, 0 AS Tour5UpdID
INTO #TmpVsaTourW
FROM Vsa
WHERE Vsa.Status = 'A'
  AND LENGTH(CONVERT(Vsa.VsaNr, SQL_VARCHAR)) = 3
GROUP BY VsaID, Vsa.VsaNr, Vsa.SuchCode, Vsa.Bez;

UPDATE VsaTourW SET VsaTourW.Tour1 = Touren.Tour
FROM #TmpVsaTourW VsaTourW, VsaTour, Touren
WHERE VsaTourW.VsaID = VsaTour.VsaID
  AND VsaTour.TourenID = Touren.ID
  AND VsaTour.KdBerID = 18
  AND Touren.Wochentag = '1';

UPDATE VsaTourW SET VsaTourW.Tour2 = Touren.Tour
FROM #TmpVsaTourW VsaTourW, VsaTour, Touren
WHERE VsaTourW.VsaID = VsaTour.VsaID
  AND VsaTour.TourenID = Touren.ID
  AND VsaTour.KdBerID = 18
  AND Touren.Wochentag = '2';
  
UPDATE VsaTourW SET VsaTourW.Tour3 = Touren.Tour
FROM #TmpVsaTourW VsaTourW, VsaTour, Touren
WHERE VsaTourW.VsaID = VsaTour.VsaID
  AND VsaTour.TourenID = Touren.ID
  AND VsaTour.KdBerID = 18
  AND Touren.Wochentag = '3';
  
UPDATE VsaTourW SET VsaTourW.Tour4 = Touren.Tour
FROM #TmpVsaTourW VsaTourW, VsaTour, Touren
WHERE VsaTourW.VsaID = VsaTour.VsaID
  AND VsaTour.TourenID = Touren.ID
  AND VsaTour.KdBerID = 18
  AND Touren.Wochentag = '4';
  
UPDATE VsaTourW SET VsaTourW.Tour5 = Touren.Tour
FROM #TmpVsaTourW VsaTourW, VsaTour, Touren
WHERE VsaTourW.VsaID = VsaTour.VsaID
  AND VsaTour.TourenID = Touren.ID
  AND VsaTour.KdBerID = 18
  AND Touren.Wochentag = '5';
  
DELETE FROM #TmpVsaTourW WHERE Tour1 = '' AND Tour2 = '' AND Tour3 = '' AND Tour4 = '' AND Tour5 = '';

UPDATE VTW SET VTW.Tour1UpdID = Touren.ID
FROM #TmpVsaTourW VTW, Touren
WHERE VTW.Tour1 = ''
  AND Touren.Tour = IIF(VTW.Tour2 <> '', LEFT(VTW.Tour2, 2) + '1' + RIGHT(VTW.Tour2, 5), IIF(VTW.Tour3 <> '', LEFT(VTW.Tour3, 2) + '1' + RIGHT(VTW.Tour3, 5), IIF(VTW.Tour4 <> '', LEFT(VTW.Tour4, 2) + '1' + RIGHT(VTW.Tour4, 5), IIF(VTW.Tour5 <> '', LEFT(VTW.Tour5, 2) + '1' + RIGHT(VTW.Tour5, 5), ''))))
  AND Touren.Wochentag = '1';

UPDATE VTW SET VTW.Tour2UpdID = Touren.ID
FROM #TmpVsaTourW VTW, Touren
WHERE VTW.Tour2 = ''
  AND Touren.Tour = IIF(VTW.Tour1 <> '', LEFT(VTW.Tour1, 2) + '2' + RIGHT(VTW.Tour1, 5), IIF(VTW.Tour3 <> '', LEFT(VTW.Tour3, 2) + '2' + RIGHT(VTW.Tour3, 5), IIF(VTW.Tour4 <> '', LEFT(VTW.Tour4, 2) + '2' + RIGHT(VTW.Tour4, 5), IIF(VTW.Tour5 <> '', LEFT(VTW.Tour5, 2) + '2' + RIGHT(VTW.Tour5, 5), ''))))
  AND Touren.Wochentag = '2';
  
UPDATE VTW SET VTW.Tour3UpdID = Touren.ID
FROM #TmpVsaTourW VTW, Touren
WHERE VTW.Tour3 = ''
  AND Touren.Tour = IIF(VTW.Tour1 <> '', LEFT(VTW.Tour1, 2) + '3' + RIGHT(VTW.Tour1, 5), IIF(VTW.Tour2 <> '', LEFT(VTW.Tour2, 2) + '3' + RIGHT(VTW.Tour2, 5), IIF(VTW.Tour4 <> '', LEFT(VTW.Tour4, 2) + '3' + RIGHT(VTW.Tour4, 5), IIF(VTW.Tour5 <> '', LEFT(VTW.Tour5, 2) + '3' + RIGHT(VTW.Tour5, 5), ''))))
  AND Touren.Wochentag = '3';
  
UPDATE VTW SET VTW.Tour4UpdID = Touren.ID
FROM #TmpVsaTourW VTW, Touren
WHERE VTW.Tour4 = ''
  AND Touren.Tour = IIF(VTW.Tour1 <> '', LEFT(VTW.Tour1, 2) + '4' + RIGHT(VTW.Tour1, 5), IIF(VTW.Tour2 <> '', LEFT(VTW.Tour2, 2) + '4' + RIGHT(VTW.Tour2, 5), IIF(VTW.Tour3 <> '', LEFT(VTW.Tour3, 2) + '4' + RIGHT(VTW.Tour3, 5), IIF(VTW.Tour5 <> '', LEFT(VTW.Tour5, 2) + '4' + RIGHT(VTW.Tour5, 5), ''))))
  AND Touren.Wochentag = '4';
  
UPDATE VTW SET VTW.Tour5UpdID = Touren.ID
FROM #TmpVsaTourW VTW, Touren
WHERE VTW.Tour5 = ''
  AND Touren.Tour = IIF(VTW.Tour1 <> '', LEFT(VTW.Tour1, 2) + '5' + RIGHT(VTW.Tour1, 5), IIF(VTW.Tour2 <> '', LEFT(VTW.Tour2, 2) + '5' + RIGHT(VTW.Tour2, 5), IIF(VTW.Tour3 <> '', LEFT(VTW.Tour3, 2) + '5' + RIGHT(VTW.Tour3, 5), IIF(VTW.Tour4 <> '', LEFT(VTW.Tour4, 2) + '5' + RIGHT(VTW.Tour4, 5), ''))))
  AND Touren.Wochentag = '5';
  
SELECT * FROM #TmpVsaTourW;

INSERT INTO VsaTour
SELECT ID, VsaID, TourenID, KdBerID, Folge, Holen, Bringen, ID AS LiefVsaTourID, StopZeit, AusliefDauer, AvgMenge, Ankunftszeit, Anlage_, Update_, User_, AnlageUser_
FROM (
	SELECT GetNextID('VSATOUR') AS ID, VsaID, Tour1UpdID AS TourenID, 18 AS KdBerID, 10 AS Folge, TRUE AS Holen, TRUE AS Bringen, -1 AS LiefVsaTourID, 0 AS StopZeit, 0 AS AusliefDauer, 0 AS AvgMenge, CONVERT(NULL, SQL_TIME) AS Ankunftszeit, NOW() AS Anlage_, NOW() AS Update_, 'STHA' AS User_, 'STHA' AS AnlageUser_
	FROM #TmpVsaTourW
	WHERE Tour1UpdID > 0
) a;

INSERT INTO VsaTour
SELECT ID, VsaID, TourenID, KdBerID, Folge, Holen, Bringen, ID AS LiefVsaTourID, StopZeit, AusliefDauer, AvgMenge, Ankunftszeit, Anlage_, Update_, User_, AnlageUser_
FROM (
	SELECT GetNextID('VSATOUR') AS ID, VsaID, Tour2UpdID AS TourenID, 18 AS KdBerID, 10 AS Folge, TRUE AS Holen, TRUE AS Bringen, -1 AS LiefVsaTourID, 0 AS StopZeit, 0 AS AusliefDauer, 0 AS AvgMenge, CONVERT(NULL, SQL_TIME) AS Ankunftszeit, NOW() AS Anlage_, NOW() AS Update_, 'STHA' AS User_, 'STHA' AS AnlageUser_
	FROM #TmpVsaTourW
	WHERE Tour2UpdID > 0
) a;

INSERT INTO VsaTour
SELECT ID, VsaID, TourenID, KdBerID, Folge, Holen, Bringen, ID AS LiefVsaTourID, StopZeit, AusliefDauer, AvgMenge, Ankunftszeit, Anlage_, Update_, User_, AnlageUser_
FROM (
	SELECT GetNextID('VSATOUR') AS ID, VsaID, Tour3UpdID AS TourenID, 18 AS KdBerID, 10 AS Folge, TRUE AS Holen, TRUE AS Bringen, -1 AS LiefVsaTourID, 0 AS StopZeit, 0 AS AusliefDauer, 0 AS AvgMenge, CONVERT(NULL, SQL_TIME) AS Ankunftszeit, NOW() AS Anlage_, NOW() AS Update_, 'STHA' AS User_, 'STHA' AS AnlageUser_
	FROM #TmpVsaTourW
	WHERE Tour3UpdID > 0
) a;

INSERT INTO VsaTour
SELECT ID, VsaID, TourenID, KdBerID, Folge, Holen, Bringen, ID AS LiefVsaTourID, StopZeit, AusliefDauer, AvgMenge, Ankunftszeit, Anlage_, Update_, User_, AnlageUser_
FROM (
	SELECT GetNextID('VSATOUR') AS ID, VsaID, Tour4UpdID AS TourenID, 18 AS KdBerID, 10 AS Folge, TRUE AS Holen, TRUE AS Bringen, -1 AS LiefVsaTourID, 0 AS StopZeit, 0 AS AusliefDauer, 0 AS AvgMenge, CONVERT(NULL, SQL_TIME) AS Ankunftszeit, NOW() AS Anlage_, NOW() AS Update_, 'STHA' AS User_, 'STHA' AS AnlageUser_
	FROM #TmpVsaTourW
	WHERE Tour4UpdID > 0
) a;

INSERT INTO VsaTour
SELECT ID, VsaID, TourenID, KdBerID, Folge, Holen, Bringen, ID AS LiefVsaTourID, StopZeit, AusliefDauer, AvgMenge, Ankunftszeit, Anlage_, Update_, User_, AnlageUser_
FROM (
	SELECT GetNextID('VSATOUR') AS ID, VsaID, Tour5UpdID AS TourenID, 18 AS KdBerID, 10 AS Folge, TRUE AS Holen, TRUE AS Bringen, -1 AS LiefVsaTourID, 0 AS StopZeit, 0 AS AusliefDauer, 0 AS AvgMenge, CONVERT(NULL, SQL_TIME) AS Ankunftszeit, NOW() AS Anlage_, NOW() AS Update_, 'STHA' AS User_, 'STHA' AS AnlageUser_
	FROM #TmpVsaTourW
	WHERE Tour5UpdID > 0
) a;