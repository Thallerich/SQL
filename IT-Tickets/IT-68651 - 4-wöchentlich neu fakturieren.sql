/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Rechnungspositionen müssen nach dem Skript manuell gelöscht werden!                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

BEGIN TRY
  BEGIN TRANSACTION;

    DECLARE @RechNr int = -11428195;

    UPDATE AbtKdArW SET RechPoID = -1
    WHERE RechPoID IN (
      SELECT RechPo.ID
      FROM RechPo
      JOIN RechKo ON RechPo.RechKoID = RechKo.ID
      WHERE RechNr = @RechNr
    );
    
    DECLARE @LsNoFakt TABLE (
      LsKoID int
    );

    UPDATE LsPo SET RechPoID = -1
    OUTPUT deleted.LsKoID INTO @LsNoFakt
    WHERE RechPoID IN (
      SELECT RechPo.ID
      FROM RechPo
      JOIN RechKo ON RechPo.RechKoID = RechKo.ID
      WHERE RechKo.RechNr = @RechNr
    );

    UPDATE LsKo SET [Status] = N'Q'
    WHERE ID IN (
      SELECT DISTINCT LsKoID
      FROM @LsNoFakt
    );

    UPDATE KdBer SET FakBisDat = N'2023-01-29', FakVonDat = N'2023-01-02'
    WHERE KdBer.KundenID IN (
        SELECT RechKo.KundenID
        FROM RechKo
        WHERE RechKo.RechNr = @RechNr
      )
      AND KdBer.FakBisDat = N'2023-02-26';

    UPDATE BrLauf SET LetzterLauf = N'2023-01-29' WHERE ID = 28 AND LetzterLauf != N'2023-01-29';

  COMMIT;

END TRY
BEGIN CATCH
  DECLARE @Message varchar(MAX) = ERROR_MESSAGE();
  DECLARE @Severity int = ERROR_SEVERITY();
  DECLARE @State smallint = ERROR_STATE();

  IF XACT_STATE() != 0
    ROLLBACK TRANSACTION;
 
  RAISERROR(@Message, @Severity, @State);
END CATCH;

GO