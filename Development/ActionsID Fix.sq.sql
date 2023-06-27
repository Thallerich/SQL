DROP TABLE IF EXISTS #ScanFix;

CREATE TABLE #ScanFix (
  ScanID bigint PRIMARY KEY CLUSTERED,
  EinzTeilID int NOT NULL,
  ScanUpdate bit DEFAULT 0,
  LastActionsID int NOT NULL DEFAULT -1,
  EinzTeilUpdate bit DEFAULT 0
);

CREATE INDEX IXTemp_ScanFix_EinzTeilID ON #ScanFix (EinzTeilID);

INSERT INTO #ScanFix (ScanID, EinzTeilID)
SELECT Scans.ID, Scans.EinzTeilID
FROM Scans
JOIN EinzHist ON Scans.EinzHistID = EinzHist.ID
JOIN EinzTeil ON EinzHist.EinzTeilID = EinzTeil.ID
WHERE Scans.ZielNrID = 10000010
  AND Scans.ActionsID = -1
  AND EinzHist.PoolFkt = 1
  AND EinzTeil.LastActionsID = -1;

DECLARE @FixedScan TABLE (
  ScanID bigint
);

WHILE (SELECT COUNT(*) FROM #ScanFix WHERE ScanUpdate = 0) > 0
BEGIN
  DELETE FROM @FixedScan;

  BEGIN TRANSACTION;
    UPDATE TOP (1000) Scans SET ActionsID = 102
    OUTPUT inserted.ID
    INTO @FixedScan (ScanID)
    WHERE Scans.ID IN (SELECT ScanID FROM #ScanFix WHERE ScanUpdate = 0);
  COMMIT;

  UPDATE #ScanFix SET ScanUpdate = 1
  WHERE ScanID IN (SELECT ScanID FROM @FixedScan);
END;

UPDATE #ScanFix SET LastActionsID = (SELECT TOP 1 Scans.ActionsID FROM Scans WHERE Scans.EinzTeilID = #ScanFix.EinzTeilID ORDER BY Scans.ID DESC);

DECLARE @FixedTeil TABLE (
  EinzTeilID int
);

WHILE (SELECT COUNT(*) FROM #ScanFix WHERE EinzTeilUpdate = 0) > 0
BEGIN
  DELETE FROM @FixedTeil;

  BEGIN TRANSACTION;
    UPDATE TOP (1000) EinzTeil SET LastActionsID = #ScanFix.LastActionsID
    OUTPUT inserted.ID
    INTO @FixedTeil (EinzTeilID)
    FROM #ScanFix
    WHERE #ScanFix.EinzTeilID = EinzTeil.ID
      AND #ScanFix.EinzTeilUpdate = 0;
  COMMIT;

  UPDATE #ScanFix SET EinzTeilUpdate = 1
  WHERE EinzTeilID IN (SELECT EinzTeilID FROM @FixedTeil);
END;