DECLARE @EndTime datetime2(3) = DATEADD(hour, 8, GETDATE());

WHILE @EndTime > GETDATE()
BEGIN

  BEGIN TRANSACTION;

  DROP TABLE IF EXISTS #TmpEinzTeilID;
  DROP TABLE IF EXISTS #TmpEinzHistID;

  SELECT TOP 750000 ID, EinzHistID, EinzTeilID INTO #TmpEinzTeilID FROM Scans WHERE EinzTeilID = -1 AND ID > -1 ORDER BY 1 DESC;
  SELECT TOP 750000 ID, EinzHistID, EinzTeilID INTO #TmpEinzHistID FROM Scans WHERE EinzHistID = -1 AND ID > -1 ORDER BY 1 DESC;

  UPDATE #TmpEinzTeilID SET EinzTeilID = EinzTeil.ID
  FROM EinzTeil
  WHERE EinzTeil.CurrEinzHistID = #TmpEinzTeilID.EinzHistID;

  UPDATE #TmpEinzHistID SET EinzHistID = EinzHist.ID
  FROM EinzHist
  WHERE EinzHist.EinzTeilID = #TmpEinzHistID.EinzTeilID;

  UPDATE Scans SET EinzTeilID = x.EinzTeilID
  FROM #TmpEinzTeilID x
  WHERE x.ID = Scans.ID;

  UPDATE Scans SET EinzHistID = x.EinzHistID
  FROM #TmpEinzHistID x
  WHERE x.ID = Scans.ID;

  COMMIT TRANSACTION;

END;