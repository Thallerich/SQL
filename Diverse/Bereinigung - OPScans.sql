USE Wozabal;
GO

DECLARE @RowsDeleted int;
DECLARE @RowsTotal int = 0;
DECLARE @RowsDeletedTotal int = 0;
DECLARE @Message nvarchar(100);

SET NOCOUNT ON;

SET @RowsTotal = (
	SELECT COUNT(*)
	FROM OPScans 
	WHERE (OPScans.AnfPoID < 0 OR OPScans.EingAnfPoID < 0 OR OPScans.LsPoID < 0)
	  AND NOT EXISTS (
      SELECT InvPo.*
      FROM InvPo
      WHERE InvPo.OPScansID = OPScans.ID
	  )
	  AND OPScans.Zeitpunkt < DATEADD(year, -2, GETDATE())
);

DELETE TOP (500000) 
FROM OPScans 
WHERE (OPScans.AnfPoID < 0 OR OPScans.EingAnfPoID < 0 OR OPScans.LsPoID < 0)
  AND NOT EXISTS (
    SELECT InvPo.*
    FROM InvPo
    WHERE InvPo.OPScansID = OPScans.ID
  )
  AND OPScans.Zeitpunkt < DATEADD(year, -2, GETDATE());

SET @RowsDeleted = @@ROWCOUNT;
SET @RowsDeletedTotal = @RowsDeletedTotal + @RowsDeleted;
SET @Message = FORMAT(GETDATE(), N'HH:mm:ss', N'de-AT') + N': Deleted ' + FORMAT(@RowsDeletedTotal, N'N', N'de-AT') + N' of ' + FORMAT(@RowsTotal, N'N', N'de-AT') + N' rows!';

RAISERROR(@Message, 0, 1) WITH NOWAIT;

WHILE @RowsDeleted > 0
BEGIN
  DELETE TOP (500000) 
  FROM OPScans 
  WHERE (OPScans.AnfPoID < 0 OR OPScans.EingAnfPoID < 0 OR OPScans.LsPoID < 0)
    AND NOT EXISTS (
      SELECT InvPo.*
      FROM InvPo
      WHERE InvPo.OPScansID = OPScans.ID
    )
    AND OPScans.Zeitpunkt < DATEADD(year, -2, GETDATE());

  SET @RowsDeleted = @@ROWCOUNT;
	SET @RowsDeletedTotal = @RowsDeletedTotal + @RowsDeleted;
	SET @Message = FORMAT(GETDATE(), N'HH:mm:ss', N'de-AT') + N': Deleted ' + FORMAT(@RowsDeletedTotal, N'N', N'de-AT') + N' of ' + FORMAT(@RowsTotal, N'N', N'de-AT') + N' rows!';

  RAISERROR(@Message, 0, 1) WITH NOWAIT;
END;