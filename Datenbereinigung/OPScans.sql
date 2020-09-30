SET NOCOUNT ON;

DECLARE @MaxRuns int = 10;
DECLARE @RowsPerBatch int = 10000;
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
  AND OPScans.ID > 0;

SET @MaxRows = @@ROWCOUNT;

WHILE (@RowsDeleted > 0 AND @RunNumber <= @MaxRuns AND @MaxRows > 0)
BEGIN

  INSERT INTO Wozabal_Archive.dbo.OPSCANS (ID, Zeitpunkt, OPTeileID, ZielNrID, ActionsID, OPGrundID, AnfPoID, ArbPlatzID, VPSPoID, EingAnfPoID, Menge, OPEtiKoID, VonLagerBewID, InvPoID, NachLagerBewID, TraegerID, ContainID, LsPoID, Anlage_, Update_, AnlageUserID_, UserID_)
  SELECT ID, Zeitpunkt, OPTeileID, ZielNrID, ActionsID, OPGrundID, AnfPoID, ArbPlatzID, VPSPoID, EingAnfPoID, Menge, OPEtiKoID, VonLagerBewID, InvPoID, NachLagerBewID, TraegerID, ContainID, LsPoID, Anlage_, Update_, AnlageUserID_, UserID_
  FROM (
    DELETE TOP (@RowsPerBatch)
    FROM OPScans WITH (ROWLOCK)
    OUTPUT deleted.*
    WHERE OPScans.ID IN (
      SELECT ID FROM #TmpScansToDelete
    )
  ) AS DeletedRows;

  SET @RowsDeleted = @@ROWCOUNT;
  SET @RowsDeletedAllRuns = @RowsDeletedAllRuns + @RowsDeleted;
  SET @Message = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss', N'de-AT') + N' - Deleted ' + FORMAT(@RowsDeletedAllRuns, N'##,#', N'de-AT') + N' of ' + FORMAT(@MaxRows, N'##,#', N'de-AT') + ' rows!  -> Run number ' + CAST(@RunNumber AS nvarchar);
  SET @RunNumber = @RunNumber + 1;
  RAISERROR(@Message, 0, 1) WITH NOWAIT;
  WAITFOR DELAY '00:00:10';

END;