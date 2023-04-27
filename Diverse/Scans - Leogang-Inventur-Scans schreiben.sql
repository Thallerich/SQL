DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');
DECLARE @ArbPlatzID int = (SELECT ID FROM ArbPlatz WHERE ComputerName = N'ATNB0003540');

DECLARE @Parts TABLE (
  EinzHistID int,
  EinzTeilID int
);

BEGIN TRY
  BEGIN TRANSACTION;
  
    INSERT INTO Scans (EinzHistID, EinzTeilID, [DateTime], ActionsID, ZielNrID, ArbPlatzID, AnlageUserID_, UserID_)
    OUTPUT inserted.EinzHistID, inserted.EinzTeilID
    INTO @Parts (EinzHistID, EinzTeilID)
    SELECT EinzHist.ID AS EinzHistID, EinzTeil.ID AS EinzTeilID, CAST(N'2023-04-12 12:00:00' AS datetime2) AS [DateTime], 120 AS ActionsID, 10000104 AS ZielNrID, @ArbPlatzID AS ArbPlatzID, @UserID AS AnlageUserID_, @UserID AS UserID_
    FROM EinzHist
    JOIN EinzTeil ON EinzHist.EinzTeilID = EinzTeil.ID
    JOIN Salesianer.dbo._LeogInv ON EinzTeil.Code = _LeogInv.EPC COLLATE Latin1_General_CS_AS
    WHERE EinzHist.IsCurrEinzHist = 1;

    UPDATE EinzTeil SET ZielNrID = 10000104, LastActionsID = 120, EinzTeil.LastScanTime = CAST(N'2023-04-12 12:00:00')
    WHERE EinzTeil.ID IN (SELECT EinzTeilID FROM @Parts)
      AND NOT EXISTS (
        SELECT Scans.*
        FROM Scans
        WHERE Scans.EinzTeilID = EinzTeil.ID
          AND Scans.[DateTime] > CAST(N'2023-04-12 12:00:00' AS datetime2)
      );
  
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