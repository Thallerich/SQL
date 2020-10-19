SET NOCOUNT ON;

DECLARE @MaxRuns int = 100;
DECLARE @RowsPerBatch int = 1000000;
DECLARE @Cutoff datetime2 = N'2017-01-01 00:00:00';

DECLARE @RunNumber int = 1;
DECLARE @RowsDeleted int = 1;
DECLARE @RowsDeletedAllRuns int = 0;
DECLARE @MaxRows int = 0;
DECLARE @Message nvarchar(100);

WHILE ((@RowsDeleted > 0) OR DATEPART(hour, GETDATE()) != 6)
BEGIN
  INSERT INTO OPScans (ID, Zeitpunkt, OpTeileID, ZielNrID, ActionsID, OpGrundID, AnfPoID, ArbPlatzID, VPSPoID, EingAnfPoID, Menge, OpEtiKoID, VonLagerBewID, InvPoID, NachLagerBewID, TraegerID, ContainID, LsPoID, Anlage_, Update_, AnlageUserID_, UserID_)
	SELECT TOP (@RowsPerBatch) ID, Zeitpunkt, OpTeileID, ZielNrID, ActionsID, OpGrundID, AnfPoID, ArbPlatzID, VPSPoID, EingAnfPoID, Menge, OpEtiKoID, VonLagerBewID, InvPoID, NachLagerBewID, TraegerID, ContainID, LsPoID, Anlage_, Update_, AnlageUserID_, UserID_
	FROM ___OPSCANS
	WHERE (LsPoID > 0 OR EingAnfPoID > 0 OR AnfPoID > 0 OR InvPoID > 0 OR OPEtiKoID > 0)
	  AND NOT EXISTS (
	    SELECT OPScans.*
			FROM OPScans
			WHERE OPScans.ID = ___OPSCANS.ID
		);

	DELETE FROM ___OPSCANS
	WHERE ID IN (
	  SELECT ID FROM OPScans
	);

  SET @RowsDeleted = @@ROWCOUNT;

  SET @RowsDeletedAllRuns = @RowsDeletedAllRuns + @RowsDeleted;
  SET @Message = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss', N'de-AT') + N' - Deleted ' + FORMAT(@RowsDeletedAllRuns, N'##,#', N'de-AT') + N' of ' + FORMAT(@MaxRows, N'##,#', N'de-AT') + ' rows!  -> Run number ' + CAST(@RunNumber AS nvarchar) + N' / ' + CAST(@MaxRuns AS nvarchar);
  SET @RunNumber = @RunNumber + 1;
  RAISERROR(@Message, 0, 1) WITH NOWAIT;
  WAITFOR DELAY '00:00:02';

END;