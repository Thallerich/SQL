DROP TABLE IF EXISTS #Auslesen;
GO

CREATE TABLE #Auslesen (
  EinzTeilID int,
  EinzHistID int
);

GO

INSERT INTO #Auslesen (EinzTeilID, EinzHistID)
SELECT EinzTeil.ID AS EinzTeilID, EinzTeil.CurrEinzHistID
FROM EinzTeil
WHERE EinzTeil.ArtikelID IN (SELECT Artikel.ID FROM Artikel WHERE Artikel.ArtikelNr IN (N'118416010001', N'118408010001'))
  AND EXISTS (
    SELECT Scans.*
    FROM Scans
    WHERE Scans.EinzTeilID = EinzTeil.ID
      AND Scans.ActionsID = 127
      AND Scans.[DateTime] BETWEEN N'2024-04-05 07:00:00.000' AND N'2024-04-05 09:00:00.000'
      AND Scans.AnlageUserID_ = (SELECT Mitarbei.ID FROM Mitarbei WHERE Mitarbei.MitarbeiUser = N'CIT-GP-FWKH-COD01')
  );

GO

DECLARE @VsaID int, @ArbPlatzID int, @UserID int;
DECLARE @Zeitpunkt datetime2;

SELECT @VsaID = Vsa.ID
FROM Vsa
WHERE Vsa.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = 19013)
  AND Vsa.VsaNr = 9951;

SELECT @ArbPlatzID = ArbPlatz.ID
FROM ArbPlatz
WHERE ArbPlatz.ComputerName = HOST_NAME();

SELECT @UserID = ID FROM Mitarbei WHERE UserName = N'THALST';

SELECT @Zeitpunkt = GETDATE();

BEGIN TRY
  BEGIN TRANSACTION;
  
    INSERT INTO Scans (EinzTeilID, EinzHistID, [DateTime], ActionsID, ZielNrID, ArbPlatzID, Menge, VsaID, Info, AnlageUserID_, UserID_)
    SELECT #Auslesen.EinzTeilID, #Auslesen.EinzHistID, @Zeitpunkt, 102, 287, @ArbPlatzID, -1, @VsaID, N'IT-81891 - Fake-Auslesen ohne Lieferschein! -- ThalSt', @UserID, @UserID
    FROM #Auslesen;

    UPDATE EinzTeil SET [Status] = N'Q', VsaID = @VsaID, LastActionsID = 102, LastScanTime = @Zeitpunkt, LastScanToKunde = @zeitpunkt, ZielNrID = 287
    WHERE ID IN (SELECT EinzTeilID FROM #Auslesen);
  
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

DROP TABLE IF EXISTS #Auslesen;
Go