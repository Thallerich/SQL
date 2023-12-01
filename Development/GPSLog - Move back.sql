/* Add a marker column on the backup table */
/* ALTER TABLE __GPSLog_Backup ADD MoveBack AS CAST(IIF(Zeitpunkt > DATEADD(day, -720, GETDATE()), 1, 0) AS bit); */

DECLARE @maxrows int = 200000;
DECLARE @maxid int = (SELECT MAX(ID) FROM __GPSLog_Backup WHERE MoveBack = 1);
DECLARE @lastid int = 0, @runmaxid int, @maxruns int, @currentrun int = 1, @realrows int;
DECLARE @statusmsg nvarchar(max);

IF (@lastid = 0) SET @lastid = ISNULL((SELECT MIN(ID) FROM __GPSLog_Backup WHERE ID > 0 AND MoveBack = 1), 1);

SET @runmaxid = @lastid + @maxrows;

-- wenn @cMinID endgültig feststeht, dann die Durchläufe ermitteln
SET @maxruns = ((@maxid - @lastid) / @maxrows) + 1;

DISABLE TRIGGER ALL ON GPSLOG;

WHILE (@maxruns >= @currentrun)
BEGIN
  BEGIN TRANSACTION;
    INSERT INTO GPSLOG (ID, MDEDevID, Zeitpunkt, GeoX, GeoY, FahrtID, Anlage_, Update_, AnlageUserID_, UserID_)
    SELECT ID, MdeDevID, Zeitpunkt, GeoX, GeoY, FahrtID, Anlage_, Update_, AnlageUserID_, UserID_
    FROM __GPSLog_Backup
    WHERE ID BETWEEN @lastid + 1 AND @runmaxid
      AND MoveBack = 1
    ORDER BY ID;

    SET @realrows = @@ROWCOUNT;      
    SET @lastid += @maxrows;
    SET @runmaxid += @maxrows;
    SET @currentrun += 1;
  COMMIT TRANSACTION;

  SET @statusmsg = FORMAT(GETDATE(), N'yyyy-mm-dd HH:MM:ss') + N': Moved ' + FORMAT(@realrows, N'N0', N'de-AT') + N'! This was run ' + FORMAT(@currentrun - 1, N'N0', N'de-AT') + N' out of ' + FORMAT(@maxruns, N'N0', N'de-AT') + N' runs total!';
  RAISERROR(N'%s', 0, 1, @statusmsg) WITH NOWAIT;
  WAITFOR DELAY N'00:00:01';
END;

ENABLE TRIGGER ALL ON GPSLOG;

GO