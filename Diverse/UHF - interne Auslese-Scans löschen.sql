SET NOCOUNT ON;
SET XACT_ABORT ON;

GO

DROP TABLE IF EXISTS #ScansForDelete;
GO

DECLARE @pznr nvarchar(20) = N'27950975';
DECLARE @rownum int = 1, @scanamount int, @msg nvarchar(max);

SELECT Scans.ID AS ScanID, Scans.EinzHistID, Scans.LsPoID, Scans.ActionsID
INTO #ScansForDelete
FROM Scans
WHERE Scans.AnfPoID IN (
    SELECT AnfPo.ID
    FROM AnfPo
    WHERE AnfPo.AnfKoID = (SELECT AnfKo.ID FROM AnfKo WHERE AnfKo.AuftragsNr = @pznr)
  );

DELETE FROM #ScansForDelete
WHERE ScanID IN (
  SELECT #ScansForDelete.ScanID
  FROM #ScansForDelete
  JOIN EinzHist ON #ScansForDelete.EinzHistID = EinzHist.ID
  WHERE EinzHist.LastLsPoID != #ScansForDelete.LsPoID
);

SELECT @scanamount = COUNT(*) FROM #ScansForDelete;

BEGIN TRY
  BEGIN TRANSACTION;

    WHILE @rownum > 0 BEGIN  
      DELETE TOP (100) FROM Scans WHERE ID IN (SELECT ScanID FROM #ScansForDelete WHERE EXISTS (SELECT 1 FROM Scans WHERE Scans.ID = #ScansForDelete.ScanID));
      SET @rownum = @@ROWCOUNT;
      SET @scanamount -= @rownum;
      SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Deleted 100 rows - ' + FORMAT(@scanamount, N'N0') + N' Scans remain'
      RAISERROR(@msg, 0, 1) WITH NOWAIT;
      WAITFOR DELAY N'00:00:01';
    END;

    UPDATE EinzHist SET LastLsPoID = -1 WHERE ID IN (SELECT EinzHistID FROM #ScansForDelete);
  
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

DROP TABLE IF EXISTS #ScansForDelete;

GO