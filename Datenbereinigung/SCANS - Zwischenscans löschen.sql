SET NOCOUNT ON;

DECLARE @rowcount int = 1;
DECLARE @deleterun int = 1, @maxrun int;
DECLARE @notify nvarchar(100);

SELECT @maxrun = (COUNT(Scans.ID) / 50000)
FROM Scans
  WHERE Scans.[DateTime] < DATEADD(day, -365, GETDATE())
    AND Scans.ActionsID NOT IN (47, 56, 52, 144)
    AND Scans.Menge = 0;

WHILE @rowcount > 0
BEGIN
  BEGIN TRANSACTION
    DELETE TOP (50000)
    FROM Scans
    WHERE Scans.[DateTime] < DATEADD(day, -365, GETDATE())
      AND Scans.ActionsID NOT IN (47, 56, 52, 144)
      AND Scans.Menge = 0;

    SELECT @rowcount = @@ROWCOUNT;
  COMMIT;

  SET @notify = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss') + N' -- Run ' + FORMAT(@deleterun, N'N0', N'de-AT') + N' / ' + FORMAT(@maxrun, N'N0', N'de-AT') + N': Deleted ' + FORMAT(50000 * @deleterun, N'N0', N'de-AT') + N' rows total!';
  RAISERROR(@notify, 0, 1) WITH NOWAIT;
  SET @deleterun += 1;
END;