DECLARE @LockStart datetime2;
DECLARE @MitarbeiName nvarchar(40);
DECLARE @LockAction nvarchar(20);
DECLARE @ErrorMessage nvarchar(100);
DECLARE @SendErrorMail bit = 0;

SET @LockStart = (
  SELECT MIN(Locking.LockStart)
  FROM Locking
  WHERE Locking.LockAction IN (N'VsaAnf-Import', N'Web-Upload')
);

IF @LockStart IS NOT NULL AND DATEDIFF(minute, @LockStart, GETDATE()) >= 30
BEGIN
  SET @SendErrorMail = 1;
  WITH LockInfo AS (
    SELECT TOP 1 Mitarbei.UserName, Locking.LockAction, Locking.LockStart
    FROM Locking
    JOIN Mitarbei ON Locking.LockMitarbeiID = Mitarbei.ID
    WHERE Locking.LockAction IN (N'VsaAnf-Import', N'Web-Upload')
    ORDER BY Locking.LockStart
  )
  SELECT @MitarbeiName = LockInfo.UserName, @LockAction = LockInfo.LockAction, @LockStart = LockInfo.LockStart
  FROM LockInfo;

  SET @ErrorMessage = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss', N'de-AT') + N' - Web-Im-/Export running to long - User: ' + @MitarbeiName + N' - Start-Time: ' + FORMAT(@LockStart, N'yyyy-MM-dd HH:mm:ss', N'de-AT') + N' - Action: ' + @LockAction;
  
  EXEC msdb.dbo.sp_send_dbmail @recipients = N's.thaller@salesianer.com', @from_address = N'no-reply@salesianer.com', @reply_to = N's.thaller@salesianer.com', @subject = N'IMPORTANT - Web-Export is blocked!', @body = @ErrorMessage, @body_format = N'TEXT', @importance = N'High', @sensitivity = N'Confidential';
END;