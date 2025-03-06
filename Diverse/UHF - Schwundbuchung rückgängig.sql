DROP TABLE IF EXISTS #SchwundRetour;
GO

CREATE TABLE #SchwundRetour (
  EinzTeilID int,
  ScanID bigint,
  SchwundEinzHistID int,
  RollbackEinzHistID int,
  ZielNrID int,
  LastActionsID int,
  LastScanTime datetime2
);

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Parameter-Definition - hier Werte anpassen!                                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @kdnr int = 20000;
DECLARE @user nchar(6) = N'ANDRSA';
DECLARE @schwundtime datetime2 = N'2025-03-06 10:00:00';

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++                                                                                                                           ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

INSERT INTO #SchwundRetour (EinzTeilID, ScanID, SchwundEinzHistID)
SELECT EinzTeil.ID AS EinzTeilID, Scans.ID AS ScanID, EinzTeil.CurrEinzHistID AS SchwundEinzHistID
FROM EinzTeil
JOIN Scans ON Scans.EinzTeilID = EinzTeil.ID
WHERE EinzTeil.VsaID IN (SELECT Vsa.ID FROM Vsa WHERE Vsa.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = @kdnr))
  AND EinzTeil.[Status] = N'W'
  AND EinzTeil.RechPoID < 0
  AND Scans.ActionsID = 116
  AND Scans.[DateTime] >= @schwundtime
  AND Scans.AnlageUserID_ = (SELECT Mitarbei.ID FROM Mitarbei WHERE Mitarbei.UserName = @user);

UPDATE #SchwundRetour SET RollbackEinzHistID = x.RollbackEinzHistID
FROM (
  SELECT EinzHist.EinzTeilID, MAX(EinzHist.ID) AS RollbackEinzHistID
  FROM EinzHist
  JOIN #SchwundRetour ON EinzHist.EinzTeilID = #SchwundRetour.EinzTeilID
  WHERE EinzHist.ID < #SchwundRetour.SchwundEinzHistID
  GROUP BY EinzHist.EinzTeilID
) x
WHERE x.EinzTeilID = #SchwundRetour.EinzTeilID;

UPDATE #SchwundRetour SET ZielNrID = x.ZielNrID, LastActionsID = x.ActionsID, LastScanTime = x.[DateTime]
FROM (
  SELECT Scans.EinzTeilID, Scans.ZielNrID, Scans.ActionsID, Scans.[DateTime]
  FROM Scans
  JOIN (
    SELECT Scans.EinzTeilID, MAX(Scans.ID) AS LastScanID
    FROM Scans
    JOIN #SchwundRetour ON Scans.EinzTeilID = #SchwundRetour.EinzTeilID
    WHERE Scans.ID < #SchwundRetour.ScanID
    GROUP BY Scans.EinzTeilID
  ) LastScan ON LastScan.LastScanID = Scans.ID
) x
WHERE x.EinzTeilID = #SchwundRetour.EinzTeilID;

GO

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = UPPER(REPLACE(USER_NAME(), N'SAL\', N'')));

BEGIN TRY
  BEGIN TRANSACTION;
  
    /* Delete Scans */
    DELETE FROM Scans WHERE ID IN (SELECT ScanID FROM #SchwundRetour);
    
    /* Restore EinzTeil */
    UPDATE EinzTeil SET [Status] = N'Q', CurrEinzHistID = #SchwundRetour.RollbackEinzHistID, ZielNrID = #SchwundRetour.ZielNrID, LastActionsID = #SchwundRetour.LastActionsID, LastScanTime = #SchwundRetour.LastScanTime, UserID_ = @userid
    FROM #SchwundRetour
    WHERE #SchwundRetour.EinzTeilID = EinzTeil.ID
      AND #SchwundRetour.RollbackEinzHistID IS NOT NULL;

    /* Delete Schwund-EinzHist */
    DELETE FROM EinzHist WHERE ID IN (SELECT SchwundEinzHistID FROM #SchwundRetour WHERE SchwundEinzHistID IS NOT NULL) AND NOT EXISTS (SELECT 1 FROM EinzTeil WHERE EinzTeil.CurrEinzHistID = EinzHist.ID);
    
    /* Restore Rollback EinzHist */
    UPDATE EinzHist SET EinzHistBis = N'2099-12-31 23:59:59.000', UserID_ = @userid
    WHERE ID IN (SELECT RollbackEinzHistID FROM #SchwundRetour WHERE RollbackEinzHistID IS NOT NULL);

  COMMIT;
END TRY
BEGIN CATCH
  DECLARE @Message varchar(MAX) = ERROR_MESSAGE();
  DECLARE @Severity int = ERROR_SEVERITY();
  DECLARE @State smallint = ERROR_STATE();
  
  IF XACT_STATE() != 0
    ROLLBACK TRANSACTION;
  
  RAISERROR(@Message, @Severity, @State) WITH NOWAIT;
END CATCH;

GO