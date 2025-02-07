SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

DROP TABLE IF EXISTS #PatchThis;
GO

DECLARE @msg nvarchar(max);
DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

SELECT EinzHist.ID AS EinzHistID, EinzHist.EinzTeilID, EinzHist.TraegerID, EinzHist.VsaID
INTO #PatchThis
FROM EinzHist
WHERE EinzHist.ID = (SELECT EinzTeil.CurrEinzHistID FROM EinzTeil WHERE EinzTeil.ID = EinzHist.EinzTeilID)
  AND EinzHist.VsaID = (SELECT Vsa.ID FROM Vsa WHERE Vsa.VsaNr = 70 AND Vsa.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = 10002655))
  AND EinzHist.[Status] = N'L';

SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - ' + CAST(@@ROWCOUNT AS nvarchar) + N' Teile müssen angepasst werden!'
RAISERROR(@msg, 0, 1) WITH NOWAIT;

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE EinzHist SET [Status] = N'N', PatchDatum = CAST(GETDATE() AS date), UserID_ = @userid
    WHERE EinzHist.ID IN (SELECT EinzHistID FROM #PatchThis);
    
    SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - ' + CAST(@@ROWCOUNT AS nvarchar) + N' EinzHist-Datensätze angepasst!'
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    UPDATE EinzTeil SET LastActionsID = 23, LastScanTime = GETDATE(), UserID_ = @userid
    WHERE EinzTeil.ID IN (SELECT EinzTeilID FROM #PatchThis);

    SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - ' + CAST(@@ROWCOUNT AS nvarchar) + N' EinzTeil-Datensätze angepasst!'
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    INSERT INTO Scans (EinzHistID, EinzTeilID, [DateTime], ActionsID, ArbPlatzID, TraegerID, VsaID, AnlageUserID_, UserID_)
    SELECT EinzHistID, EinzTeilID, GETDATE() AS [DateTime], 23 AS ActionsID, 2240 AS ArbPlatzID, TraegerID, VsaID, @userid AS AnlageUserID_, @userid AS UserID_
    FROM #PatchThis;

    SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - ' + CAST(@@ROWCOUNT AS nvarchar) + N' Scans geschrieben!'
    RAISERROR(@msg, 0, 1) WITH NOWAIT;
  
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