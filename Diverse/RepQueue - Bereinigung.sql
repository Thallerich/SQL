/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Inzing                                                                                                                    ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

CREATE TABLE #Cleanup (
  Seq int,
  SdcScanID int
);

INSERT INTO #Cleanup (Seq, SdcScanID)
SELECT RepQueue.Seq, SdcScan.ID
FROM RepQueue
JOIN SdcScan ON RepQueue.TableID = SdcScan.ID AND RepQueue.TableName = N'SDCSCAN'
WHERE SdcScan.AdvInstID = SdcScan.SdcDevID;

BEGIN TRY
  BEGIN TRANSACTION;
  
    DELETE FROM RepQueue WHERE Seq IN (SELECT Seq FROM #Cleanup);
    DELETE FROM SdcScan WHERE ID IN (SELECT SdcScanID FROM #Cleanup);
  
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