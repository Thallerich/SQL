SET NOCOUNT ON;

DECLARE @RunNumber int = 1;
DECLARE @RowsDeleted int = 1;
DECLARE @Message nvarchar(100);
DECLARE @Cutoff datetime2 = N'2019-01-01 00:00:00';

WHILE (@RowsDeleted > 0 AND @RunNumber <= 10)
BEGIN

  INSERT INTO Wozabal_Archive.dbo.OPSCANS (ID, Zeitpunkt, OPTeileID, ZielNrID, ActionsID, OPGrundID, AnfPoID, ArbPlatzID, VPSPoID, EingAnfPoID, Menge, OPEtiKoID, VonLagerBewID, InvPoID, NachLagerBewID, TraegerID, ContainID, LsPoID, Anlage_, Update_, AnlageUserID_, UserID_)
  SELECT ID, Zeitpunkt, OPTeileID, ZielNrID, ActionsID, OPGrundID, AnfPoID, ArbPlatzID, VPSPoID, EingAnfPoID, Menge, OPEtiKoID, VonLagerBewID, InvPoID, NachLagerBewID, TraegerID, ContainID, LsPoID, Anlage_, Update_, AnlageUserID_, UserID_
  FROM (
    DELETE TOP (50000)
    FROM OPScans
    OUTPUT deleted.*
    WHERE OPScans.Zeitpunkt < @Cutoff
      AND OPScans.AnfPoID = -1
      AND OPScans.EingAnfPoID = -1
      AND OPScans.OPGrundID = -1
      AND OPScans.OPEtiKoID = -1
      AND OPScans.InvPoID = -1
      AND OPScans.TraegerID = -1
      AND OPScans.ContainID = -1
      AND OPScans.LsPoID = -1
  ) AS DeletedRows;

  SET @RowsDeleted = @@ROWCOUNT;
  SET @Message = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss', N'de-AT') + N' - Deleted ' + CAST(@RowsDeleted AS nvarchar) + ' rows!  -> Run number ' + CAST(@RunNumber AS nvarchar);
  SET @RunNumber = @RunNumber + 1;
  RAISERROR(@Message, 0, 1);
END;