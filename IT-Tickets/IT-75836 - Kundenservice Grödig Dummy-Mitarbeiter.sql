DECLARE @serviceid int = (SELECT Mitarbei.ID FROM Mitarbei WHERE Mitarbei.MaNr = N'SMS5001');

DECLARE @KdBer TABLE (
  KdBerID int PRIMARY KEY CLUSTERED,
  KundenID int
);

BEGIN TRY
  BEGIN TRANSACTION;
  
    /* TODO: Add Code here! */
    UPDATE KdBer SET ServiceID = @serviceid
    OUTPUT inserted.ID, inserted.KundenID INTO @KdBer (KdBerID, KundenID)
    WHERE KundenID IN (
        SELECT Kunden.ID
        FROM Kunden
        WHERE Kunden.StandortID = (SELECT Standort.ID FROM Standort WHERE Standort.SuchCode = N'SMS')
      )
      AND KdBer.ServiceID != @serviceid;

    UPDATE VsaBer SET ServiceID = @serviceid
    WHERE KdBerID IN (SELECT KdBerID FROM @KdBer);

    UPDATE WebUser SET MitarbeiID = @serviceid
    WHERE KundenID IN (SELECT KundenID FROM @KdBer);
  
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