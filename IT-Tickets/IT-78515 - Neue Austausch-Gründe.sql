DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE WegGrund SET Austausch = 0 WHERE Austausch = 1;

    INSERT INTO WegGrund (WeggrundBez, WeggrundBez2, WeggrundBez3, WeggrundBez4, WeggrundBez5, WeggrundBez7, WeggrundBez8, WeggrundBez9, WeggrundBezA, Austausch, UserID_, AnlageUserID_)
    SELECT WeggrundBez, WeggrundBez2, WeggrundBez3, WeggrundBez4, WeggrundBez5, WeggrundBez7, WeggrundBez8, WeggrundBez9, WeggrundBezA, CAST(1 AS bit) AS Austausch, @UserID AS UserID_, @UserID AS AnlageUserID_
    FROM _IT78515;
  
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