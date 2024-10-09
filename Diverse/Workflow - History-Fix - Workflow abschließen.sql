SET NOCOUNT ON;
SET XACT_ABORT ON;

GO

DROP TABLE IF EXISTS #WfFix;
GO

/* 
SELECT History.ID AS HistoryID, History.TableName, History.LinkTableName, History.LinkTableID, WfKo.WfKoBez, WfPo.WfPoBez, WfExit.ExitBez, WfExit.NextWfPoID, WfExit.WfAbschlussStatus
FROM History
JOIN WfPo ON History.CurrentWfPoID = WfPo.ID
JOIN WfKo ON WfPo.WfKoID = WfKo.ID
JOIN WfExit ON WfExit.WfPoID = WfPo.ID
WHERE History.WfKoID > 0
  AND History.CurrentWfPoID > 0
  AND WfExit.NextWfPoID = -1
  AND WfExit.WfAbschlussStatus IS NOT NULL;
*/

DECLARE @msg nvarchar(max), @fixcount int;

SELECT History.ID AS HistoryID, WfExit.WfAbschlussStatus
INTO #WfFix
FROM History
JOIN WfPo ON History.CurrentWfPoID = WfPo.ID
JOIN WfKo ON WfPo.WfKoID = WfKo.ID
JOIN WfExit ON WfExit.WfPoID = WfPo.ID
WHERE History.WfKoID > 0
  AND History.CurrentWfPoID > 0
  AND WfExit.NextWfPoID = -1
  AND WfExit.WfAbschlussStatus IS NOT NULL;


SELECT @msg = FORMAT(@@ROWCOUNT, N'N0') + N' History entries need Workflow-Exit-Fix!';

RAISERROR(@msg, 0, 1) WITH NOWAIT;

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE History SET [Status] = WfAbschlussStatus, CurrentWfPoID = -1
    FROM #WfFix
    WHERE #WfFix.HistoryID = History.ID
      AND (#WfFix.WfAbschlussStatus != History.[Status] OR History.CurrentWfPoID != -1);

    SELECT @fixcount = @@ROWCOUNT;
  
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

SELECT @msg = FORMAT(@fixcount, N'N0') +  N' History entries have been fixed, workflows have been set to finished!';
RAISERROR(@msg, 0, 1) WITH NOWAIT;

GO