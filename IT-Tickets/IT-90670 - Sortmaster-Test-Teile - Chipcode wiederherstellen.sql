SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

DROP TABLE IF EXISTS #RestoreChip;
GO

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');
DECLARE @runtime AS datetime2 = GETDATE();
DECLARE @msg nvarchar(max);

SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - Chipcode-Verheiratung für Teile beim Kunden 10000079 wiederherstellen!';
RAISERROR(@msg, 0, 1) WITH NOWAIT;

SELECT EinzHist.ID, EinzHist.EinzTeilID, Chipcode = (SELECT TOP 1 ChipHist.RentomatChip FROM EinzHist AS ChipHist WHERE ChipHist.EinzTeilID = EinzHist.EinzTeilID AND ChipHist.EinzHistBis <= EinzHist.EinzHistVon AND ChipHist.RentomatChip IS NOT NULL AND LEN(ChipHist.RentomatChip) = 24 ORDER BY ChipHist.EinzHistBis DESC)
INTO #RestoreChip
FROM EinzHist
WHERE EinzHist.ID = (SELECT EinzTeil.CurrEinzHistID FROM EinzTeil WHERE EinzTeil.ID = EinzHist.EinzTeilID)
  AND EinzHist.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = 10000079)
  AND EinzHist.[Status] = N'N'
  AND EinzHist.EinzHistTyp = 1
  AND EinzHist.RentomatChip IS NULL;

SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - ' + CAST(@@ROWCOUNT AS nvarchar) + N' Teile gefunden, bei denen der Chipcode wiederhergestellt werden soll.';
RAISERROR(@msg, 0, 1) WITH NOWAIT;

DELETE FROM #RestoreChip WHERE Chipcode IS NULL;

SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - Für ' + CAST(@@ROWCOUNT AS nvarchar) + N' Teile wurde kein Chipcode gefunden.';
RAISERROR(@msg, 0, 1) WITH NOWAIT;

DELETE FROM #RestoreChip WHERE ID IN (
  SELECT ID 
  FROM (
    SELECT ID, DENSE_RANK() OVER (PARTITION BY Chipcode ORDER BY ID DESC) AS SortRank
    FROM #RestoreChip
  ) AS x
  WHERE x.SortRank > 1
);

SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - ' + CAST(@@ROWCOUNT AS nvarchar) + N' Teile mit doppeltem Chipcode werden ignortiert.';
RAISERROR(@msg, 0, 1) WITH NOWAIT;

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE EinzHist SET RentomatChip = #RestoreChip.Chipcode, UserID_ = @userid
    FROM #RestoreChip
    WHERE #RestoreChip.ID = EinzHist.ID
      AND EinzHist.RentomatChip IS NULL
      AND NOT EXISTS (
        SELECT eh.*
        FROM EinzHist AS eh
        WHERE eh.RentomatChip = #RestoreChip.Chipcode
          AND eh.ID = (SELECT EinzTeil.CurrEinzHistID FROM EinzTeil WHERE EinzTeil.ID = eh.EinzTeilID)
      );

    SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - ' + CAST(@@ROWCOUNT AS nvarchar) + N' EinzHist-Einträge mit Chipcode aktualisiert.';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    UPDATE EinzTeil SET Code2 = #RestoreChip.Chipcode, UserID_ = @userid
    FROM #RestoreChip
    WHERE #RestoreChip.EinzTeilID = EinzTeil.ID
      AND EinzTeil.Code2 IS NULL
      AND NOT EXISTS (
        SELECT et.*
        FROM EinzTeil AS et
        WHERE et.Code2 = #RestoreChip.Chipcode
      );

    SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - ' + CAST(@@ROWCOUNT AS nvarchar) + N' EinzTeil-Einträge mit Chipcode aktualisiert.';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;
  
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

SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - Fertig!';
RAISERROR(@msg, 0, 1) WITH NOWAIT;

GO

DROP TABLE #RestoreChip;
GO