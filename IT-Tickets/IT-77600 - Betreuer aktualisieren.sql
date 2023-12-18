BEGIN TRY
  BEGIN TRANSACTION;
  
    /* TODO: Add Code here! */
    WITH ImportTable AS (
      SELECT KundenID, VsaID, BereichID, KdBerBetreuerID, VsaBerBetreuerID
      FROM _IT77600
    )
    UPDATE KdBer SET BetreuerID = ImportTable.KdBerBetreuerID
    FROM ImportTable
    WHERE KdBer.KundenID = ImportTable.KundenID
      AND KdBer.BereichID = ImportTable.BereichID
      AND KdBer.BetreuerID != ImportTable.KdBerBetreuerID;
  
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

BEGIN TRY
  BEGIN TRANSACTION;
  
    /* TODO: Add Code here! */
    WITH ImportTable AS (
      SELECT KundenID, VsaID, BereichID, KdBerBetreuerID, VsaBerBetreuerID
      FROM _IT77600
    )
    UPDATE VsaBer SET BetreuerID = ImportTable.VsaBerBetreuerID
    FROM ImportTable, KdBer
    WHERE VsaBer.KdBerID = KdBer.ID
      AND VsaBer.VsaID = ImportTable.VsaID
      AND KdBer.BereichID = ImportTable.BereichID
      AND VsaBer.BetreuerID != ImportTable.VsaBerBetreuerID;
  
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