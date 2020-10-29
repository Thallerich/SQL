SET NOCOUNT ON;

DECLARE @DeletedRows int = 1;
DECLARE @DeletedRowsAll int = 0;
DECLARE @MaxRows int = 0;
DECLARE @Message nvarchar(100);

SET @MaxRows = (
  SELECT COUNT(RepQueue.Seq)
  FROM RepQueue
  WHERE RepQueue.SdcDevID = 51
);

WHILE @DeletedRows > 0 BEGIN
  DELETE TOP (1000)
  FROM RepQueue
  WHERE RepQueue.SdcDevID = 51;

  SET @DeletedRows = @@ROWCOUNT;
  SET @DeletedRowsAll = @DeletedRowsAll + @DeletedRows;

  SET @Message = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss', N'de-AT') + N' - Deleted ' + FORMAT(@DeletedRowsAll, N'##,#', N'de-AT') + ' rows out of ' + FORMAT(@MaxRows, N'##,#', N'de-AT') + '!';
  RAISERROR(@Message, 0, 1) WITH NOWAIT;

  WAITFOR DELAY N'00:00:10';
END;