/*

--DROP TABLE __RepQueue_20250616;

--SELECT TOP 0 * INTO __RepQueue_20250616 FROM RepQueue;
--SET IDENTITY_INSERT __RepQueue_20250616 ON;

EXEC('CREATE VIEW dbo.RepQueueMove AS SELECT TOP 1000 * FROM dbo.RepQueue WHERE Priority > 999 ORDER BY Seq ASC;'); /* View muss über "dynamisches" SQL erstellt werden, da das CREATE VIEW ansonsten einen eigenen Batch benötigt würden! */

DECLARE @EndTime datetime2(3) = DATEADD(minute, 60, GETDATE());  /* Skript läuft maximal 60 Minuten */
DECLARE @IsError bit = 0;
DECLARE @DeleteCount int = 1;

WHILE (@EndTime > GETDATE() AND @DeleteCount > 0)
BEGIN
  BEGIN TRY
    BEGIN TRANSACTION
    
      DELETE FROM dbo.RepQueueMove
      OUTPUT deleted.Seq, deleted.Typ, deleted.TableName, deleted.TableID, deleted.ApplicationID, deleted.SdcDevID, deleted.Priority, deleted.ErrorCounter, deleted.NextProcTime, deleted.Anlage_
      INTO __RepQueue_20250616 (Seq, Typ, TableName, TableID, ApplicationID, SdcDevID, Priority, ErrorCounter, NextProcTime, Anlage_);

      SET @DeleteCount = @@ROWCOUNT;

    COMMIT;
  END TRY
  BEGIN CATCH
    DECLARE @Message nvarchar(max) = ERROR_MESSAGE();
    DECLARE @Severity int = ERROR_SEVERITY();
    DECLARE @State smallint = ERROR_STATE();

    SET @IsError = 1;

    IF XACT_STATE() != 0
      ROLLBACK TRANSACTION;
  
    RAISERROR(@Message, @Severity, @State);
  END CATCH;

  IF @IsError = 1
    BREAK;
  
END;

DROP VIEW dbo.RepQueueMove;

*/

WITH ReInsert AS (
  SELECT TOP (15000) *
  FROM __RepQueue_20250616
  ORDER BY SdcDevID, [Priority] ASC
)
DELETE
FROM ReInsert
OUTPUT deleted.Typ, deleted.TableName, deleted.TableID, deleted.ApplicationID, deleted.SdcDevID, deleted.Priority, deleted.ErrorCounter, deleted.NextProcTime, deleted.Anlage_
INTO RepQueue (Typ, TableName, TableID, ApplicationID, SdcDevID, Priority, ErrorCounter, NextProcTime, Anlage_);