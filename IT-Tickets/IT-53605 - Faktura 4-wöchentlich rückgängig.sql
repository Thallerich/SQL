DECLARE @rechnr int = -11757538;
DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

BEGIN TRY
  BEGIN TRANSACTION;

    UPDATE AbtKdArW SET RechPoID = -1, UserID_ = @userid
    WHERE RechPoID IN (
      SELECT RechPo.ID
      FROM RechPo
      JOIN FakLauf ON RechPo.FakLaufID = FakLauf.ID
      WHERE RechPo.RechKoID = (SELECT ID FROM RechKo WHERE RechNr = @rechnr)
        AND FakLauf.Restwerte = 0
    );

    DECLARE @LsNoFakt TABLE (
      LsKoID int
    );

    UPDATE LsPo SET RechPoID = -1, UserID_ = @userid
    OUTPUT deleted.LsKoID INTO @LsNoFakt
    WHERE RechPoID IN (
      SELECT RechPo.ID
      FROM RechPo
      JOIN FakLauf ON RechPo.FakLaufID = FakLauf.ID
      WHERE RechPo.RechKoID = (SELECT ID FROM RechKo WHERE RechNr = @rechnr)
        AND FakLauf.Restwerte = 0
    );

    UPDATE LsKo SET [Status] = N'Q'
    WHERE ID IN (
      SELECT DISTINCT LsKoID
      FROM @LsNoFakt
    );

    DECLARE @RKoDel TABLE (
      RechKoID int,
      KdBerID int
    );

    DELETE FROM RechPo
    OUTPUT deleted.RechKoID, deleted.KdBerID INTO @RKoDel (RechKoID, KdBerID)
    WHERE ID IN (
      SELECT RechPo.ID
      FROM RechPo
      JOIN FakLauf ON RechPo.FakLaufID = FakLauf.ID
      WHERE RechPo.RechKoID = (SELECT ID FROM RechKo WHERE RechNr = @rechnr)
        AND FakLauf.Restwerte = 0
    );

    DELETE FROM RechKo
    WHERE ID IN (
        SELECT DISTINCT RechKoID
        FROM @RKoDel
      )
      AND NOT EXISTS (
        SELECT RechPo.*
        FROM RechPo
        WHERE RechPo.RechKoID = RechKo.ID
      );

    UPDATE KdBer SET FakBisDat = DATEADD(week, -4, FakBisDat), FakVonDat = DATEADD(week, -4, FakVonDat)
    WHERE KdBer.ID IN (SELECT KdBerID FROM @RKoDel);
  
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
