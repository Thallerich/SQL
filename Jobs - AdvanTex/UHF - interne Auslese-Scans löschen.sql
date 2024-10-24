DROP TABLE IF EXISTS #ScansForDelete;

DECLARE @vsaid int = 6165451; /* KdNr 25202, VsaNr 12325 -- interne Belieferung von GP Enns nach Enns SH */
DECLARE @rownum int = 0, @scanamount int = 0, @msg nvarchar(max);

SELECT Scans.ID AS ScanID, Scans.EinzHistID, Scans.LsPoID, Scans.ActionsID
INTO #ScansForDelete
FROM Scans
JOIN AnfPo ON Scans.AnfPoID = AnfPo.ID
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN EinzHist ON Scans.EinzHistID = EinzHist.ID
WHERE AnfKo.VsaID = @vsaid
  AND AnfKo.LieferDatum >= CAST(GETDATE() AS date)
  AND EinzHist.LastLsPoID = Scans.LsPoID;

SELECT @scanamount = COUNT(*) FROM #ScansForDelete;

IF @scanamount > 0
BEGIN
  BEGIN TRY
    BEGIN TRANSACTION;

      WHILE @scanamount > 0 BEGIN  
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
END;

DROP TABLE IF EXISTS #ScansForDelete;