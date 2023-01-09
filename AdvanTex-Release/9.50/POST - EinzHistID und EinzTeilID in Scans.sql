SET NOCOUNT ON;

DECLARE @EndTime datetime2(3) = DATEADD(hour, 8, GETDATE());
DECLARE @IsError bit = 0;
DECLARE @RunCounter int = 1;
DECLARE @Msg nvarchar(100);

WHILE @EndTime > GETDATE()
BEGIN
  SET @Msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - Beginning run ' + CAST(@RunCounter AS nvarchar) + '!';
  RAISERROR(@Msg, 0, 1) WITH NOWAIT;

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

  BEGIN TRY
    BEGIN TRANSACTION
    
      UPDATE Scans SET EinzTeilID = x.EinzTeilID
      FROM #TmpEinzTeilID x
      WHERE x.ID = Scans.ID;

      SET @Msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - EinzTeilID: ' + CAST(@@ROWCOUNT AS nvarchar) + N' rows updated!';
      RAISERROR(@Msg, 0, 1) WITH NOWAIT;

      UPDATE Scans SET EinzHistID = x.EinzHistID
      FROM #TmpEinzHistID x
      WHERE x.ID = Scans.ID;

      SET @Msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - EinzHistID: ' + CAST(@@ROWCOUNT AS nvarchar) + N' rows updated!';
      RAISERROR(@Msg, 0, 1) WITH NOWAIT;

    COMMIT;
  END TRY
  BEGIN CATCH
    DECLARE @Message nvarchar(max) = ERROR_MESSAGE();
    DECLARE @Severity int = ERROR_SEVERITY();
    DECLARE @State smallint = ERROR_STATE();

    SET @IsError = 1;

    IF XACT_STATE() != 0
      ROLLBACK TRANSACTION;
  
    RAISERROR(@Message, @Severity, @State);
  END CATCH;

  IF @IsError = 1
    BREAK;
  
  SET @RunCounter += 1;

END;