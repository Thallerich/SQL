SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

/* 
CREATE INDEX IX_Timestamp_Function ON SalExLog (Anlage_, FunctionName) INCLUDE (HttpRequest, ResponseReturnDescriptio, ResponseSuccessful) WITH (DATA_COMPRESSION = PAGE);
*/

CREATE VIEW dbo.SalExLog_Delete AS
  SELECT TOP 1000 *
  FROM dbo.SalExLog
  WHERE Anlage_ < N'2021-01-01 00:00:00.000'
  ORDER BY ID ASC;

GO

DECLARE @EndTime datetime2(3) = DATEADD(minute, 30, GETDATE());
DECLARE @IsError bit = 0;
DECLARE @RunCounter int = 1, @DeleteCount int = 1;
DECLARE @Msg nvarchar(100);

WHILE (@EndTime > GETDATE() AND @DeleteCount > 0)
BEGIN
  SET @Msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - Beginning run ' + CAST(@RunCounter AS nvarchar) + '!';
  RAISERROR(@Msg, 0, 1) WITH NOWAIT;

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
  
  SET @RunCounter += 1;

END;

GO

DROP VIEW dbo.SalExLog_Delete;
GO

/*

EXEC Salesianer_Archive.dbo.sp_BlitzIndex @DatabaseName = N'Salesianer', @TableName = N'SALEXLOG';

*/