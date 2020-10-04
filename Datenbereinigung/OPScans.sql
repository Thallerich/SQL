SET NOCOUNT ON;

DECLARE @MaxRuns int = 100;
DECLARE @RowsPerBatch int = 1000000;
DECLARE @Cutoff datetime2 = N'2017-01-01 00:00:00';

DECLARE @RunNumber int = 1;
DECLARE @RowsDeleted int = 1;
DECLARE @RowsDeletedAllRuns int = 0;
DECLARE @MaxRows int = 0;
DECLARE @Message nvarchar(100);

DROP TABLE IF EXISTS #TmpScansToDelete;

SELECT TOP (@RowsPerBatch * @MaxRuns) OPScans.ID
INTO #TmpScansToDelete
FROM OPScans
WHERE OPScans.Zeitpunkt < @Cutoff
  AND OPScans.AnfPoID = -1
  AND OPScans.EingAnfPoID = -1
  AND OPScans.OPGrundID = -1
  AND OPScans.OPEtiKoID = -1
  AND OPScans.InvPoID = -1
  AND OPScans.TraegerID = -1
  AND OPScans.ContainID = -1
  AND OPScans.LsPoID = -1
  AND OPScans.ID > 0
  AND NOT EXISTS (
    SELECT InvPo.*
    FROM InvPo
    WHERE InvPo.OPScansID = OPScans.ID
  );

SET @MaxRows = @@ROWCOUNT;

CREATE INDEX IX_OPScansID ON #TmpScansToDelete (ID);

SET @Message = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss', N'de-AT') + N' - Temp-Table done!';
RAISERROR(@Message, 0, 1) WITH NOWAIT;

DISABLE TRIGGER RI_OPSCANS_DELETE ON OPScans;

SET @Message = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss', N'de-AT') + N' - Trigger deactivated!';
RAISERROR(@Message, 0, 1) WITH NOWAIT;

WHILE ((@RowsDeleted > 0 AND @RunNumber <= @MaxRuns AND @MaxRows > 0) OR DATEPART(hour, GETDATE()) != 6)
BEGIN

  INSERT INTO Wozabal_Archive.dbo.OPSCANS (ID, Zeitpunkt, OPTeileID, ZielNrID, ActionsID, OPGrundID, AnfPoID, ArbPlatzID, VPSPoID, EingAnfPoID, Menge, OPEtiKoID, VonLagerBewID, InvPoID, NachLagerBewID, TraegerID, ContainID, LsPoID, Anlage_, Update_, AnlageUserID_, UserID_)
  SELECT TOP (@RowsPerBatch) ID, Zeitpunkt, OPTeileID, ZielNrID, ActionsID, OPGrundID, AnfPoID, ArbPlatzID, VPSPoID, EingAnfPoID, Menge, OPEtiKoID, VonLagerBewID, InvPoID, NachLagerBewID, TraegerID, ContainID, LsPoID, Anlage_, Update_, AnlageUserID_, UserID_
  FROM OPScans
  WHERE OPScans.ID IN (SELECT ID FROM #TmpScansToDelete)
    AND NOT EXISTS (
      SELECT AOPScans.*
      FROM Wozabal_Archive.dbo.OPSCANS AS AOPScans
      WHERE AOPScans.ID = OPScans.ID
    );

  SET @Message = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss', N'de-AT') + N' - INSERT done!';
  RAISERROR(@Message, 0, 1) WITH NOWAIT;

  BEGIN TRANSACTION;
    
    DELETE TOP (@RowsPerBatch)
    FROM OPScans WITH (ROWLOCK)
    WHERE OPScans.ID IN (
      SELECT ID FROM #TmpScansToDelete
    );

    SET @RowsDeleted = @@ROWCOUNT;

  COMMIT;

  SET @RowsDeletedAllRuns = @RowsDeletedAllRuns + @RowsDeleted;
  SET @Message = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss', N'de-AT') + N' - Deleted ' + FORMAT(@RowsDeletedAllRuns, N'##,#', N'de-AT') + N' of ' + FORMAT(@MaxRows, N'##,#', N'de-AT') + ' rows!  -> Run number ' + CAST(@RunNumber AS nvarchar) + N' / ' + CAST(@MaxRuns AS nvarchar);
  SET @RunNumber = @RunNumber + 1;
  RAISERROR(@Message, 0, 1) WITH NOWAIT;
  WAITFOR DELAY '00:00:02';

END;

ENABLE TRIGGER RI_OPSCANS_DELETE ON OPScans;

SET @Message = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss', N'de-AT') + N' - Trigger activated!';
RAISERROR(@Message, 0, 1) WITH NOWAIT;

DROP TABLE IF EXISTS #TmpScansToDelete;
