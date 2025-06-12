SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

DROP TABLE IF EXISTS #LsNachweisCleanup;
GO

SELECT LsKo.ID, CAST(0 AS bit) AS Processed
INTO #LsNachweisCleanup
FROM LsKo
WHERE LsKo.SendLsNachweis = 2
  AND LsKo.Datum < CAST(GETDATE() AS date)
  AND LsKo.LsNr != 57605508;

GO

DECLARE @work TABLE (ID int);
DECLARE @msg nvarchar(max);
DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = UPPER(REPLACE(ORIGINAL_LOGIN(), N'SAL\', N'')));

WHILE (SELECT COUNT(*) FROM #LsNachweisCleanup WHERE Processed = 0) > 0
BEGIN
  BEGIN TRY
    
    BEGIN TRANSACTION;
    
      UPDATE LsKo SET SendLsNachweis = 1, UserID_ = @userid
      OUTPUT inserted.ID INTO @work (ID)
      WHERE ID IN (SELECT TOP 1000 ID FROM #LsNachweisCleanup WHERE Processed = 0);

      UPDATE #LsNachweisCleanup SET Processed = 1
      WHERE ID IN (SELECT ID FROM @work);
    
    COMMIT;

    DELETE FROM @work;
    
    SET @msg = FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss') + ': ' + CAST((SELECT COUNT(*) FROM #LsNachweisCleanup WHERE Processed = 0) AS nvarchar(10)) + ' records left.';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

  END TRY
  BEGIN CATCH
    DECLARE @Message varchar(MAX) = ERROR_MESSAGE();
    DECLARE @Severity int = ERROR_SEVERITY();
    DECLARE @State smallint = ERROR_STATE();
    
    IF XACT_STATE() != 0
      ROLLBACK TRANSACTION;
    
    RAISERROR(@Message, @Severity, @State) WITH NOWAIT;
  END CATCH;
END;

GO