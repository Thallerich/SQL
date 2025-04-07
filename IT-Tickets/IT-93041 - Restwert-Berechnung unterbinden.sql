SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

DROP TABLE IF EXISTS #NoInvoicing;
GO

SELECT DISTINCT TeilSoFa.ID, CAST(0 AS bit) AS Processed
INTO #NoInvoicing
FROM TeilSoFa
JOIN EinzHist ON TeilSoFa.EinzHistID = EinzHist.ID
WHERE EinzHist.Barcode IN (
    SELECT Barcode COLLATE Latin1_General_CS_AS
    FROM _IT93041
  )
  AND TeilSoFa.SoFaArt = 'R'
  AND TeilSoFa.RechPoID < 0
  AND TeilSoFa.[Status] = N'L';

GO

DECLARE @work TABLE (ID int);
DECLARE @msg nvarchar(max);
DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = UPPER(REPLACE(USER_NAME(), N'SAL\', N'')));

WHILE (SELECT COUNT(*) FROM #NoInvoicing WHERE Processed = 0) > 0
BEGIN
  BEGIN TRY
    BEGIN TRANSACTION;
    
      UPDATE TeilSoFa SET [Status] = 'D', OhneBerechGrund = 14, UserID_ = @userid
      OUTPUT inserted.ID INTO @work (ID)
      WHERE ID IN (SELECT TOP 100 ID FROM #NoInvoicing WHERE Processed = 0);

      UPDATE #NoInvoicing SET Processed = 1
      WHERE ID IN (SELECT ID FROM @work);
    
    COMMIT;

    DELETE FROM @work;
    
    SET @msg = FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss') + ': ' + CAST((SELECT COUNT(*) FROM #NoInvoicing WHERE Processed = 0) AS nvarchar(10)) + ' records left.';
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