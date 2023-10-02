SET NOCOUNT ON;

DECLARE @maxcount int, @lastcount int = 1, @cutoffdate datetime2;

SET @cutoffdate = DATEADD(day, DATEDIFF(day, 0, DATEADD(day, -180, GETDATE())), 0); /* 180 Tage von heute zurück um 00:00 Uhr */

SELECT @maxcount = COUNT(*)
FROM SAWR_Log.dbo.Logs
WHERE Logs.[Timestamp] < @cutoffdate;

IF @maxcount = 0
  PRINT N'Nothing to do!';
ELSE
BEGIN
  WHILE @lastcount > 0
  BEGIN
    BEGIN TRY
      BEGIN TRANSACTION;
  
        DELETE TOP (10000)
        FROM SAWR_Log.dbo.Logs
        WHERE Logs.[Timestamp] < @cutoffdate;

        SET @lastcount = @@ROWCOUNT;
  
      COMMIT;
    END TRY
    BEGIN CATCH
      DECLARE @Message varchar(MAX) = ERROR_MESSAGE();
      DECLARE @Severity int = ERROR_SEVERITY();
      DECLARE @State smallint = ERROR_STATE();
  
      IF XACT_STATE() != 0
        ROLLBACK TRANSACTION;
  
      RAISERROR(@Message, @Severity, @State) WITH NOWAIT;

      SET @lastcount = 0;
    END CATCH;

    WAITFOR DELAY N'00:00:01';
  END

  PRINT N'Deleted ' + CAST(@maxcount AS nvarchar) + N' rows!';

END;