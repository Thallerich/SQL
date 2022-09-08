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

USE dbSystem;
GO

UPDATE TabField SET [Name] = N'FahrtID'
FROM TabName 
WHERE TabField.TabNameID = TabName.ID
  AND TabName.TabName = N'SCANS'
  AND TabField.[Name] = N'AltOpScansID';

GO

UPDATE TabIndex SET [TagName] = N'FahrtID', [Expression] = N'FahrtID'
FROM TabName
WHERE TabIndex.TabNameID = TabName.ID
  AND TabName.TabName = N'SCANS'
  AND TabIndex.TagName = N'AltOpScansID';

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ FahrtID NOT NULL und DEFAULT -1                                                                                           ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

USE Salesianer;
GO

DROP INDEX SCANS.FahrtID;
GO
ALTER TABLE SCANS ADD CONSTRAINT SCANS_FahrtIDDefault DEFAULT -1 FOR FahrtID;
GO
UPDATE SCANS SET FahrtID = -1 WHERE FahrtID IS NULL;
GO
ALTER TABLE SCANS ALTER COLUMN FahrtID int NOT NULL WITH (ONLINE = ON);
GO
CREATE INDEX FahrtID ON SCANS (FahrtID) WITH (ONLINE = ON);
GO

USE dbSystem;
GO

UPDATE TabField SET Bez = N'frühere OpScansID', BezEN = N'previous OpScansID', NotNullDD = 1, RefTableName = N'FAHRT', RefFieldName = N'ID', RestrictDelete = 1, AllowMinus1 = 1, RefChkMode = 2, DefaultValue = N'-1', ToDoNr = N'129935', IgnoreRefCheckMsSQL = 1, User_ = N'TERBRACK', OldName = N'AltOpScansID'
FROM TabName
WHERE TabField.TabNameID = TabName.ID
  AND TabName.TabName = N'SCANS'
  AND TabField.Name = N'FahrtID';

GO