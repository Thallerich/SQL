/* 
DROP TABLE __KundenAnsprechpartner;
 */

IF OBJECT_ID(N'__KundenAnsprechpartner') IS NULL
BEGIN

  PRINT N'Importing data from Excel file...';

  DECLARE @ImportFile nvarchar(200) = N'\\ATENADVANTEX01.wozabal.int\AdvanTex\Temp\Ansprechpartner Kunden.xlsx';
  DECLARE @XLSXImportSQL nvarchar(max);

  CREATE TABLE __KundenAnsprechpartner (
    ImportID int IDENTITY(1, 1),
    KdNr int,
    Kunde nvarchar(50) COLLATE Latin1_General_CS_AS,
    Anrede nvarchar(20) COLLATE Latin1_General_CS_AS,
    Titel nvarchar(20) COLLATE Latin1_General_CS_AS,
    Vorname nvarchar(20) COLLATE Latin1_General_CS_AS,
    Nachname nvarchar(40) COLLATE Latin1_General_CS_AS,
    Abteilung nvarchar(40) COLLATE Latin1_General_CS_AS,
    Position nvarchar(40) COLLATE Latin1_General_CS_AS,
    Rollen nvarchar(200) COLLATE Latin1_General_CS_AS,
    eMail nvarchar(80) COLLATE Latin1_General_CS_AS,
    Telefon nvarchar(30) COLLATE Latin1_General_CS_AS,
    Mobil nvarchar(30) COLLATE Latin1_General_CS_AS,
    SachbearID int,
    ActionTaken nchar(10)
  );

  SET @XLSXImportSQL = N'SELECT Kunde, Anrede, Titel, Vorname, Name, Abteilung, Position, Rollen, eMail, Telefon, Mobil ' +
    N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [Ansprechpartner$]);';

  INSERT INTO __KundenAnsprechpartner (Kunde, Anrede, Titel, Vorname, Nachname, Abteilung, [Position], Rollen, eMail, Telefon, Mobil)
  EXEC sp_executesql @XLSXImportSQL;

  PRINT N'Done importing!';

  PRINT N'Seperating customer number into it''s own column';

  UPDATE __KundenAnsprechpartner SET KdNr = CAST(LEFT(Kunde, CHARINDEX(N' ', Kunde, 1) - 1) AS int);

END
ELSE
  PRINT N'Import-Table already exists - continuing with data already present!';

GO

DECLARE @MergeOutput TABLE (
  ImportID int,
  SachbearID int,
  ActionTaken nchar(10)
);

DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ TODO:                                                                                                                     ++ */
/* ++   - Delete existing which are not present in ImportData   ✔                                                               ++ */
/* ++   - Update / Insert SachRoll after MERGE                  ✔                                                               ++ */
/* ++   - Fill SerienAnrede in MERGE                            ✔                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

MERGE INTO Sachbear
USING (
  SELECT Kunden.ID AS KundenID, __KundenAnsprechpartner.*, LEFT(REPLACE(REPLACE(REPLACE(Anrede.SerienAnrede, N'[NACHNAME]', ISNULL(RTRIM(__KundenAnsprechpartner.Nachname), N'')), N'[VORNAME]', ISNULL(RTRIM(__KundenAnsprechpartner.Vorname), N'')), N'[TITEL]', ISNULL(RTRIM(__KundenAnsprechpartner.Titel), N'')), 40) AS SerienAnrede
  FROM __KundenAnsprechpartner
  JOIN Kunden ON __KundenAnsprechpartner.KdNr = Kunden.KdNr
  LEFT JOIN Anrede ON __KundenAnsprechpartner.Anrede = Anrede.Anrede
) AS ImportData (KundenID, ImportID, KdNr, Kunde, Anrede, Titel, Vorname, Nachname, Abteilung, Position, Rollen, eMail, Telefon, Mobil, SachbearID, ActionTaken, SerienAnrede)
ON Sachbear.TableID = ImportData.KundenID AND Sachbear.TableName = N'KUNDEN' AND ISNULL(Sachbear.Name, N'') = ISNULL(ImportData.Nachname, N'') AND ISNULL(Sachbear.Vorname, N'') = ISNULL(ImportData.Vorname, N'') AND ISNULL(Sachbear.eMail, N'') = ISNULL(ImportData.eMail, N'') AND ISNULL(Sachbear.Abteilung, N'') = ISNULL(ImportData.Abteilung, N'')
WHEN MATCHED THEN
  UPDATE SET Sachbear.AnzeigeName = ISNULL(ImportData.Nachname, N'') + ISNULL(N', ' + ImportData.Titel, N'') + ISNULL(N', ' + ImportData.Vorname, N''), Sachbear.Anrede = ImportData.Anrede, Sachbear.Titel = ImportData.Titel, Sachbear.Abteilung = ImportData.Abteilung, Sachbear.Position = ImportData.Position, Sachbear.Telefon = ImportData.Telefon, Sachbear.Mobil = ImportData.Mobil, Sachbear.eMail = ImportData.eMail, Sachbear.SerienAnrede = ImportData.SerienAnrede, Sachbear.UserID_ = @UserID
WHEN NOT MATCHED THEN
  INSERT (TableID, TableName, [Status], AnzeigeName, Anrede, Titel, Vorname, [Name], Abteilung, Position, Telefon, Mobil, eMail, SerienAnrede, Anlage_, AnlageUserID_, UserID_)
    VALUES (ImportData.KundenID, N'KUNDEN', N'A', ISNULL(ImportData.Nachname, N'') + ISNULL(N', ' + ImportData.Titel, N'') + ISNULL(N', ' + ImportData.Vorname, N''), ImportData.Anrede, ImportData.Titel, ImportData.Vorname, ImportData.Nachname, ImportData.Abteilung, ImportData.Position, ImportData.Telefon, ImportData.Mobil, ImportData.eMail, ImportData.SerienAnrede, GETDATE(), @UserID, @UserID)
OUTPUT ImportData.ImportID, inserted.ID AS SachbearID, $action AS ActionTaken
INTO @MergeOutput;

UPDATE __KundenAnsprechpartner SET SachbearID = MergeOutput.SachbearID, ActionTaken = MergeOutput.ActionTaken
FROM __KundenAnsprechpartner
JOIN @MergeOutput MergeOutput ON MergeOutput.ImportID = __KundenAnsprechpartner.ImportID;

UPDATE Sachbear SET [Status] = N'I', UserID_ = @UserID
FROM Sachbear
JOIN Kunden ON Sachbear.TableID = Kunden.ID
WHERE Sachbear.TableName = N'KUNDEN'
  AND Sachbear.ID NOT IN (SELECT SachbearID FROM __KundenAnsprechpartner WHERE SachbearID IS NOT NULL)
  AND Kunden.KdNr IN (SELECT KdNr FROM __KundenAnsprechpartner WHERE SachbearID IS NOT NULL)
  AND Sachbear.Status = N'A';

MERGE INTO SachRoll
USING (
  SELECT KdAExploded.SachbearID, Rollen.ID AS RollenID
  FROM (
    SELECT __KundenAnsprechpartner.*, LTRIM(RTRIM(value)) AS Rolle
    FROM __KundenAnsprechpartner
    CROSS APPLY STRING_SPLIT(Rollen, N',')
    WHERE __KundenAnsprechpartner.SachbearID IS NOT NULL
  )KdAExploded
  JOIN Rollen ON KdAExploded.Rolle = Rollen.RollenBez
  WHERE KdAExploded.SachbearID IS NOT NULL
) AS ImportRollen (SachbearID, RollenID)
ON ImportRollen.SachbearID = SachRoll.SachbearID AND ImportRollen.RollenID = SachRoll.RollenID
WHEN NOT MATCHED BY TARGET THEN
  INSERT (SachbearID, RollenID, Anlage_, AnlageUserID_, UserID_)
    VALUES (ImportRollen.SachbearID, ImportRollen.RollenID, GETDATE(), @UserID, @UserID)
WHEN NOT MATCHED BY SOURCE THEN
  DELETE;

GO