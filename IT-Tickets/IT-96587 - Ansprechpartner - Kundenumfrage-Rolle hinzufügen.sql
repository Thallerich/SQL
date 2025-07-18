SET XACT_ABORT ON;
GO

DROP TABLE IF EXISTS #AddSachRoll;
GO

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = UPPER(REPLACE(ORIGINAL_LOGIN(), N'SAL\', N'')));
DECLARE @roleid int = (SELECT ID FROM Rollen WHERE RollenBez = N'Kontakt Kundenumfrage');

SELECT Kunden.ID AS KundenID, Kunden.KdNr, CombinedSachbear.ID AS SachbearID, _IT96587.Anrede, _IT96587.Titel, _IT96587.Vorname, _IT96587.Nachname, _IT96587.eMail, Anrede.SerienAnrede
INTO #AddSachRoll
FROM Salesianer.dbo._IT96587
JOIN Kunden ON _IT96587.KdNr = Kunden.KdNr
LEFT JOIN Anrede ON _IT96587.Anrede = Anrede.Anrede AND Kunden.LanguageID = Anrede.LanguageID
LEFT JOIN (
  SELECT Sachbear.ID, Sachbear.eMail, Sachbear.TableID AS KundenID
  FROM Sachbear
  WHERE Sachbear.TableName = N'KUNDEN'

  UNION ALL

  SELECT Sachbear.ID, Sachbear.eMail, Vsa.KundenID
  FROM Sachbear
  JOIN Vsa ON Sachbear.TableID = Vsa.ID
  WHERE Sachbear.TableName = N'VSA'
) AS CombinedSachbear ON CombinedSachbear.eMail = _IT96587.eMail AND CombinedSachbear.KundenID = Kunden.ID;

DECLARE @NewSachbear TABLE (
  SachbearID bigint,
  eMail nvarchar(80) COLLATE Latin1_General_CS_AS
);

BEGIN TRY
  BEGIN TRANSACTION;

    INSERT INTO Sachbear (TableName, TableID, AnzeigeName, Anrede, Titel, Vorname, [Name], eMail, SerienAnrede, AnlageUserID_, UserID_)
    OUTPUT inserted.ID, inserted.eMail INTO @NewSachbear (SachbearID, eMail)
    SELECT N'KUNDEN' AS TableName, #AddSachRoll.KundenID AS TableID, ISNULL(#AddSachRoll.Nachname, N'') + ISNULL(N', ' + #AddSachRoll.Vorname, N'') AS AnzeigeName, #AddSachRoll.Anrede, #AddSachRoll.Titel, #AddSachRoll.Vorname, #AddSachRoll.Nachname AS [Name], #AddSachRoll.eMail, LEFT(REPLACE(REPLACE(#AddSachRoll.SerienAnrede, N' [TITEL]', ISNULL(N' ' + #AddSachRoll.Titel, N'')), N'[NACHNAME]', #AddSachRoll.Nachname), 40) AS SerienAnrede, @userid AS AnlageUserID_, @userid AS UserID_
    FROM #AddSachRoll
    WHERE #AddSachRoll.SachbearID IS NULL;

    UPDATE #AddSachRoll SET SachbearID = [@NewSachbear].SachbearID
    FROM @NewSachbear
    WHERE #AddSachRoll.eMail = [@NewSachbear].eMail
      AND #AddSachRoll.SachbearID IS NULL;
  
    INSERT INTO SachRoll (SachbearID, RollenID, AnlageUserID_, UserID_)
    SELECT DISTINCT #AddSachRoll.SachbearID, @roleid AS RollenID, @userid AS AnlageUserID_, @userid AS UserID_
    FROM #AddSachRoll
    WHERE NOT EXISTS (
      SELECT 1
      FROM SachRoll
      WHERE SachRoll.SachbearID = #AddSachRoll.SachbearID
        AND SachRoll.RollenID = @roleid
    );
  
  COMMIT;
END TRY
BEGIN CATCH
  DECLARE @Message varchar(MAX) = ERROR_MESSAGE();
  DECLARE @Severity int = ERROR_SEVERITY();
  DECLARE @State smallint = ERROR_STATE();
  
  IF XACT_STATE() != 0
    ROLLBACK TRANSACTION;
  
  RAISERROR(@Message, @Severity, @State) WITH NOWAIT;
END CATCH;

GO

DROP TABLE #AddSachRoll;

GO