SET NOCOUNT ON;
SET XACT_ABORT ON;

GO

DECLARE @RechTypFix TABLE (
  RechKoID int
);

INSERT INTO @RechTypFix (RechKoID)
SELECT RechKo.ID
FROM RechKo WITH (UPDLOCK)
WHERE EXISTS (
    SELECT RechPo.*
    FROM RechPo
    WHERE RechPo.RechKoID = RechKo.ID
      AND RechPo.Bez = N'Schwundverrechnung'
  )
  AND RechKo.AnlageUserID_ = (SELECT ID FROM Mitarbei WHERE UserName = N'SVOBKU')
  AND RechKo.Anlage_ >= N'2024-12-04 00:00:00.000'
  AND RechKo.RKoTypeID != (SELECT ID FROM RKoType WHERE RKoTypeBez = N'Schwundverrechnung UHF-Pool');

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE RechKo SET RKoTypeID = (SELECT ID FROM RKoType WHERE RKoTypeBez = N'Schwundverrechnung UHF-Pool')
    WHERE ID IN (SELECT RechKoID FROM @RechTypFix);
  
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