SET NOCOUNT ON;

DECLARE @MaxRuns int = 100;
DECLARE @RowsPerBatch int = 10000;

DECLARE @RunNumber int = 1;
DECLARE @RowsInserted int = 1;
DECLARE @RowsInsertedAllRuns int = 0;
DECLARE @RowsDeleted int = 0;
DECLARE @Message nvarchar(100);

WHILE (@RowsInserted > 0 AND @RunNumber <= @MaxRuns)
BEGIN
  INSERT INTO Salesianer.dbo.OPScans (ID, Zeitpunkt, OpTeileID, ZielNrID, ActionsID, OpGrundID, AnfPoID, ArbPlatzID, VPSPoID, EingAnfPoID, Menge, OpEtiKoID, VonLagerBewID, InvPoID, NachLagerBewID, TraegerID, ContainID, LsPoID, Anlage_, Update_, AnlageUserID_, UserID_)
  SELECT TOP (@RowsPerBatch) ID, Zeitpunkt, OpTeileID, ZielNrID, ActionsID, OpGrundID, AnfPoID, ArbPlatzID, VPSPoID, EingAnfPoID, Menge, OpEtiKoID, VonLagerBewID, InvPoID, NachLagerBewID, TraegerID, ContainID, LsPoID, Anlage_, Update_, AnlageUserID_, UserID_
  FROM Salesianer.dbo.___OPSCANS
  WHERE NOT EXISTS (
      SELECT OPScans.*
      FROM Salesianer.dbo.OPScans
      WHERE OPScans.ID = ___OPSCANS.ID
  );

  SET @RowsInserted = @@ROWCOUNT;

  SET @RowsInsertedAllRuns = @RowsInsertedAllRuns + @RowsInserted;
  SET @Message = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss', N'de-AT') + N' - Inserted ' + FORMAT(@RowsInsertedAllRuns, N'##,#', N'de-AT') + ' rows!  -> Run number ' + CAST(@RunNumber AS nvarchar) + N' / ' + CAST(@MaxRuns AS nvarchar);
  SET @RunNumber = @RunNumber + 1;
  RAISERROR(@Message, 0, 1) WITH NOWAIT;
END;

DELETE FROM Salesianer.dbo.___OPSCANS
WHERE ID IN (
  SELECT ID FROM Salesianer.dbo.OPScans
);

SET @RowsDeleted = @@ROWCOUNT;

SET @Message = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss', N'de-AT') + N' - Deleted ' + FORMAT(@RowsDeleted, N'##,#', N'de-AT') + ' rows!';
RAISERROR(@Message, 0, 1);