CREATE VIEW dbo.SalExLog_Delete AS
  SELECT TOP 1000 *
  FROM dbo.SalExLog
  WHERE Anlage_ < DATEADD(month, -6, GETDATE())
  ORDER BY ID ASC;

GO

DECLARE @EndTime datetime2(3) = DATEADD(minute, 60, GETDATE());  /* Skript läuft maximal 60 Minuten */
DECLARE @IsError bit = 0;
DECLARE @DeleteCount int = 1;

WHILE (@EndTime > GETDATE() AND @DeleteCount > 0)
BEGIN
  BEGIN TRY
    BEGIN TRANSACTION
    
      DELETE FROM dbo.SalExLog_Delete;

      SET @DeleteCount = @@ROWCOUNT;

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
  
END;

DROP VIEW dbo.SalExLog_Delete;