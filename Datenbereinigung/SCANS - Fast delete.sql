SET NOCOUNT ON;
GO

CREATE VIEW dbo.Scans_Delete AS
  SELECT TOP 1000 *
  FROM dbo.Scans
  WHERE ActionsID NOT IN (47, 56, 52, 144)
    AND Menge = 0
    AND AnfPoID < 0
    AND EingAnfPoID < 0
    AND InvPoID < 0
    AND LsPoID < 0
    AND LotID < 0
    AND WaschChID < 0
    AND VpsPoID < 0
    AND OPEtiKoID < 0
  ORDER BY [DateTime] ASC;

GO

DECLARE @EndTime datetime2(3) = DATEADD(minute, 120, GETDATE());
DECLARE @IsError bit = 0;
DECLARE @RunCounter int = 1;
DECLARE @Msg nvarchar(100);

WHILE @EndTime > GETDATE()
BEGIN
  SET @Msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - Beginning run ' + CAST(@RunCounter AS nvarchar) + '!';
  RAISERROR(@Msg, 0, 1) WITH NOWAIT;

    BEGIN TRY
    BEGIN TRANSACTION
    
      DELETE FROM dbo.Scans_Delete
      WHERE [DateTime] < N'2020-01-01 00:00:00.000';

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

DROP VIEW dbo.Scans_Delete;
GO