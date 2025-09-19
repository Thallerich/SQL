SET NOCOUNT ON;
SET XACT_ABORT ON;

GO

DROP TABLE IF EXISTS #TeilAppl;

GO

DECLARE @customer int = 300545;

SELECT TeilAppl.ID
INTO #TeilAppl
FROM TeilAppl WITH (UPDLOCK)
JOIN EinzHist ON TeilAppl.EinzHistID = EinzHist.ID
JOIN Kunden ON EinzHist.KundenID = Kunden.ID
WHERE EinzHist.ID = (SELECT EinzTeil.CurrEinzHistID FROM EinzTeil WHERE EinzTeil.ID = EinzHist.EinzTeilID)
  AND Kunden.KdNr = @customer
  AND EinzHist.[Status] >= 'Q'
  AND TeilAppl.Bearbeitung != '-'
OPTION (MAXDOP 1);

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = UPPER(REPLACE(ORIGINAL_LOGIN(), N'SAL\', N'')));
DECLARE @msg nvarchar(max);

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE TeilAppl SET Bearbeitung = '-', BestaetDatum = CAST(GETDATE() AS date), BestaetMitarbeiID = @userid, UserID_ = @userid
    WHERE ID IN (SELECT ID FROM #TeilAppl);

    SET @msg = FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss') + N': ' + CAST(@@ROWCOUNT AS nvarchar) + N' Applikationen auf Bearbeitung = ''-'' gesetzt.';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;
  
  ROLLBACK;
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