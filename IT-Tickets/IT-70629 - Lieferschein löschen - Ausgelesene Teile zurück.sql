IF OBJECT_ID(N'tempdb..#UndoExpedit') IS NULL
  CREATE TABLE #UndoExpedit (
    ScansID bigint,
    EinzTeilID int,
    EinzHistID int
  )
ELSE
  DELETE FROM #UndoExpedit;

GO

INSERT INTO #UndoExpedit (ScansID, EinzTeilID, EinzHistID)
SELECT Scans.ID AS ScansID, Scans.EinzTeilID, Scans.EinzHistID
FROM Scans
JOIN LsPo ON Scans.LsPoID = LsPo.ID
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
WHERE LsKo.LsNr IN (48117985, 48137260, 48134837, 48150581, 48148810)
  AND NOT EXISTS (
    SELECT s.*
    FROM Scans s
    WHERE s.EinzHistID = Scans.EinzHistID
      AND s.[DateTime] > Scans.[DateTime]
  );

GO

BEGIN TRY
  BEGIN TRANSACTION;
  
    DELETE FROM Scans
    WHERE ID IN (
      SELECT ScansID
      FROM #UndoExpedit
    );

    UPDATE EinzTeil SET EinzTeil.LastScanTime = y.[DateTime], EinzTeil.ZielNrID = y.ZielNrID , EinzTeil.LastActionsID = y.ActionsID
    FROM (
      SELECT x.EinzTeilID, Scans.[DateTime], Scans.ZielNrID, Scans.ActionsID
      FROM (
        SELECT #UndoExpedit.EinzTeilID, LastScanID = (SELECT TOP 1 Scans.ID FROM Scans WHERE Scans.ID < #UndoExpedit.ScansID AND Scans.EinzTeilID = #UndoExpedit.EinzTeilID ORDER BY Scans.ID DESC)
        FROM #UndoExpedit
      ) x
      JOIN Scans ON x.LastScanID = Scans.ID
    ) y
    WHERE y.EinzTeilID = EinzTeil.ID;

    UPDATE EinzHist SET Ausgang1 = NULL, LastLsPoID = -1, FirstLsPoID = -1
    WHERE EinzHist.ID IN (SELECT EinzHistID FROM #UndoExpedit);
  
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