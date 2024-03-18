SET NOCOUNT ON;
GO
/* 
CREATE INDEX IX_ScanDelete ON dbo.SCANS ([DateTime])
INCLUDE (ActionsID, Menge, AnfPoID, EingAnfPoID, InvPoID, LsPoID, LotID, WaschChID, VpsPoID, OPEtiKoID)
WHERE ActionsID <> 47
  AND ActionsID <> 56
  AND ActionsID <> 52
  AND ActionsID <> 144
  AND Menge = 0
  AND AnfPoID = -1
  AND EingAnfPoID = -1
  AND InvPoID = -1
  AND LsPoID = -1
  AND LotID = -1
  AND WaschChID = -1
  AND VpsPoID = -1
  AND OPEtiKoID = -1
WITH (DATA_COMPRESSION = PAGE);

GO

DROP INDEX IX_ScanDelete ON dbo.SCANS;
GO
 */
CREATE VIEW dbo.Scans_Delete AS
  SELECT TOP 1000 *
  FROM dbo.Scans
  WHERE ActionsID NOT IN (47, 56, 52, 144)
    AND Menge = 0
    AND AnfPoID = -1
    AND EingAnfPoID = -1
    AND InvPoID = -1
    AND LsPoID = -1
    AND LotID = -1
    AND WaschChID = -1
    AND VpsPoID = -1
    AND OPEtiKoID = -1
  ORDER BY [DateTime] ASC;

GO

DECLARE @EndTime datetime2(3) = DATEADD(minute, 60, GETDATE());
DECLARE @IsError bit = 0;
DECLARE @RunCounter int = 1, @DeleteCount int = 1;
DECLARE @Msg nvarchar(100);

WHILE (@EndTime > GETDATE() AND @DeleteCount > 0)
BEGIN
  SET @Msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - Beginning run ' + CAST(@RunCounter AS nvarchar) + '!';
  RAISERROR(@Msg, 0, 1) WITH NOWAIT;

    BEGIN TRY
    BEGIN TRANSACTION
    
      DELETE FROM dbo.Scans_Delete
      WHERE [DateTime] < N'2020-01-01 00:00:00.000';

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

DROP VIEW dbo.Scans_Delete;
GO