SET XACT_ABORT ON;

GO

DROP TABLE IF EXISTS #DateFix;

GO

DECLARE @week nchar(7) = N'2025/08';
DECLARE @date date = (SELECT [Week].VonDat FROM [Week] WHERE [Week].Woche = @week);
DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = UPPER(REPLACE(ORIGINAL_LOGIN(), N'SAL\', N'')));

SELECT EinzHist.ID AS EinzHistID, EinzTeil.ID AS EinzTeilID
INTO #DateFix
FROM EinzHist
JOIN EinzTeil ON EinzHist.EinzTeilID = EinzTeil.ID
WHERE EinzHist.KundenID = (SELECT ID FROM Kunden WHERE KdNr = 10007582)
  AND EinzHist.Indienst >= N'2026/01'
  AND (SELECT Status FROM EinzHist AS currEinzHist WHERE currEinzHist.ID = EinzTeil.CurrEinzHistID) = N'Q';

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE EinzHist SET Indienst = @week, IndienstDat = @date, UserID_ = @userid
    WHERE ID IN (SELECT EinzHistID FROM #DateFix);

    UPDATE EinzTeil SET ErstDatum = @date, UserID_ = @userid
    WHERE ID IN (SELECT EinzTeilID FROM #DateFix);
  
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

DROP TABLE #DateFix;

GO