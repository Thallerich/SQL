SET NOCOUNT ON;
GO

IF COL_LENGTH('SCANS','AltOpScansID') IS NOT NULL
BEGIN
  DECLARE @SQL NVARCHAR(MAX); 
  SET @SQL = '
  -- -1-Datensätze gesondert aktualisieren. Daurch sparen wir uns Durchläufe, 
  -- wenn die kleinste "echte" dann z.B. 1.300.000 ist.
  UPDATE SCANS
  SET SCANS.AltOpScansID = -1
  WHERE SCANS.ID <= -1;

  DECLARE @AnzRecords INTEGER = 200000; 
  DECLARE @MaxID INTEGER = (SELECT MAX(ID) FROM SCANS WHERE SCANS.ID > -1); 
  DECLARE @cMinID INTEGER = ISNULL((SELECT MIN(ID) FROM SCANS WHERE SCANS.ID > -1), 1); 
  DECLARE @cMaxID INTEGER; SET @cMaxID = @cMinID + @AnzRecords - 1; 
  DECLARE @Runs INTEGER = ((@MaxID - @cMinID) / @AnzRecords) + 1; 
  DECLARE @MaxRuns INTEGER = @Runs;
  DECLARE @RunCounter INTEGER = 1;
  DECLARE @Message nvarchar(max);

  WHILE (@Runs > 0) BEGIN 
    BEGIN TRANSACTION 

    UPDATE SCANS SET SCANS.AltOpScansID = -1
    FROM SCANS WITH ( INDEX (PK_Scans) )
    WHERE SCANS.ID BETWEEN @cMinID and @cMaxID;

    SET @Message = N''Completed run '' + CAST(@RunCounter AS nvarchar) + N'' out of '' + CAST(@MaxRuns AS nvarchar) + N'' runs!'';
    RAISERROR(@Message,0,0) WITH NOWAIT;

    SET @cMinID = @cMinID + @AnzRecords; 
    SET @cMaxID = @cMaxID + @AnzRecords; 
    SET @Runs = @Runs - 1;
    SET @RunCounter += 1;

    COMMIT TRANSACTION
  END';
  
  EXEC(@SQL);

  -- Feld direkt umbenennen
  EXEC sp_rename 'SCANS.AltOpScansID', 'FahrtID', 'COLUMN';
  -- Index anlegen, dann sparen wir uns das bei der Datenbankanpassung und können diesen 
  -- direkt für das Skript zum neuen "NOT NULL"-Constraint nutzen!
  CREATE INDEX FahrtID ON SCANS (FahrtID);
END;

GO