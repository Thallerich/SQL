SET NOCOUNT ON;

DECLARE @MaxRuns int = 10000;
DECLARE @RowsPerBatch int = 3000;
DECLARE @MaxTemp int = @MaxRuns * @RowsPerBatch;

DECLARE @RunNumber int = 1;
DECLARE @RowsInserted int = 1;
DECLARE @RowsInsertedAllRuns int = 0;
DECLARE @RowsDeleted int = 0;
DECLARE @Message nvarchar(100);

DECLARE @ScansRestored TABLE (
  OPScansID int
);

DROP TABLE IF EXISTS #TmpRestoreOPScans;

SELECT TOP (@MaxTemp) ID, Zeitpunkt, OpTeileID, ZielNrID, ActionsID, OpGrundID, AnfPoID, ArbPlatzID, VPSPoID, EingAnfPoID, Menge, OpEtiKoID, VonLagerBewID, InvPoID, NachLagerBewID, TraegerID, ContainID, LsPoID, Anlage_, Update_, AnlageUserID_, UserID_
INTO #TmpRestoreOPScans
FROM Salesianer.dbo.___OPSCANS
WHERE NOT EXISTS (
    SELECT OPScans.*
    FROM Salesianer.dbo.OPScans
    WHERE OPScans.ID = ___OPSCANS.ID
  )
  AND EXISTS (
    SELECT AnfPo.*
    FROM Salesianer.dbo.AnfPo
    WHERE AnfPo.ID = ___OPSCANS.AnfPoID
  )
  AND ___OPSCANS.AnfPoID > 0
  /*OR NOT EXISTS (
    SELECT InvPo.*
    FROM Salesianer.dbo.InvPo
    WHERE InvPo.ID = ___OPSCANS.InvPoID
  ) */
  AND EXISTS (
    SELECT OPTeile.*
    FROM Salesianer.dbo.OPTeile
    WHERE OPTeile.ID = ___OPSCANS.OPTeileID
  )
ORDER BY ID DESC;

WHILE (@RowsInserted > 0 AND @RunNumber <= @MaxRuns)
BEGIN

  DELETE FROM @ScansRestored;

  INSERT INTO Salesianer.dbo.OPScans (ID, Zeitpunkt, OpTeileID, ZielNrID, ActionsID, OpGrundID, AnfPoID, ArbPlatzID, VPSPoID, EingAnfPoID, Menge, OpEtiKoID, VonLagerBewID, InvPoID, NachLagerBewID, TraegerID, ContainID, LsPoID, Anlage_, Update_, AnlageUserID_, UserID_)
  OUTPUT inserted.ID
  INTO @ScansRestored (OPScansID)
  SELECT TOP (@RowsPerBatch) ID, Zeitpunkt, OpTeileID, ZielNrID, ActionsID, OpGrundID, AnfPoID, ArbPlatzID, VPSPoID, EingAnfPoID, Menge, OpEtiKoID, VonLagerBewID, InvPoID, NachLagerBewID, TraegerID, ContainID, LsPoID, Anlage_, Update_, AnlageUserID_, UserID_
  FROM #TmpRestoreOPScans;

  SET @RowsInserted = @@ROWCOUNT;

  SET @RowsInsertedAllRuns = @RowsInsertedAllRuns + @RowsInserted;
  SET @Message = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss', N'de-AT') + N' - Inserted ' + FORMAT(@RowsInsertedAllRuns, N'##,#', N'de-AT') + ' rows!  -> Run number ' + CAST(@RunNumber AS nvarchar) + N' / ' + CAST(@MaxRuns AS nvarchar);
  IF @RunNumber % 1000 = 0 RAISERROR(@Message, 0, 1) WITH NOWAIT;
  SET @RunNumber = @RunNumber + 1;

  DELETE FROM #TmpRestoreOPScans
  WHERE ID IN (
    SELECT OPScansID FROM @ScansRestored
  );
END;

DELETE FROM Salesianer.dbo.___OPSCANS
WHERE ID IN (
  SELECT ID FROM Salesianer.dbo.OPScans
);

SET @RowsDeleted = @@ROWCOUNT;

SET @Message = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss', N'de-AT') + N' - Deleted ' + FORMAT(@RowsDeleted, N'##,#', N'de-AT') + ' rows!';
RAISERROR(@Message, 0, 1);