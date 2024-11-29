SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

SET CONTEXT_INFO 0x1; /* AdvanTex-Trigger für RepQueue deaktivieren */
GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Schrott-Teile                                                                                                             ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #Cleanup;
GO

CREATE TABLE #Cleanup (
  EinzHistID int PRIMARY KEY CLUSTERED,
  EinzHistID_Schrott int,
  EinzTeilID int,
  Barcode varchar(33) COLLATE Latin1_General_CS_AS,
  KundenID int,
  VsaID int,
  TraegerID int,
  TraeArtiID int,
  KdArtiID int,
  ArtikelID int,
  ArtGroeID int,
  Ausdienst varchar(7),
  AusdienstDat date,
  AusdienstGrund varchar(1)
);

CREATE NONCLUSTERED INDEX IX_Cleanup ON #Cleanup (EinzTeilID);

GO

DECLARE @weggrundid int = 167; /* IT -> Schrott */
DECLARE @curdatetime datetime2 = GETDATE();
DECLARE @returntime datetime2 = DATEADD(millisecond, -10, @curdatetime);
DECLARE @ausdienstweek varchar(7) = (SELECT [Week].Woche FROM [Week] WHERE CAST(GETDATE() AS date) BETWEEN [Week].VonDat AND [Week].BisDat);
DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST')
DECLARE @arbplatzid int = (SELECT ID FROM ArbPlatz WHERE ComputerName = HOST_NAME());
DECLARE @msg nvarchar(max);

DECLARE @MapTable TABLE (
  EinzTeilID int,
  EinzHistID int
);

SELECT @msg = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss', N'de-AT') + N': Teile für Schrott in Temp-Table laden';
RAISERROR(@msg, 0, 1) WITH NOWAIT;

INSERT INTO #Cleanup (EinzHistID, EinzTeilID, Barcode, KundenID, VsaID, TraegerID, TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, Ausdienst, AusdienstDat, AusdienstGrund)
SELECT EinzHist.ID, EinzHist.EinzTeilID, EinzHist.Barcode, EinzHist.KundenID, EinzHist.VsaID, EinzHist.TraegerID, EinzHist.TraeArtiID, EinzHist.KdArtiID, EinzHist.ArtikelID, EinzHist.ArtGroeID, EinzHist.Ausdienst, EinzHist.AusdienstDat, EinzHist.AusdienstGrund
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN Kunden ON EinzHist.KundenID = Kunden.ID
WHERE EinzHist.Barcode IN (SELECT Barcode FROM _IT88919)
  AND EinzHist.EinzHistTyp = 1;

SELECT @msg = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss', N'de-AT') + N': Anzahl zu verschrottende Teile = ' + FORMAT(@@ROWCOUNT, N'N0', N'de-AT');
RAISERROR(@msg, 0, 1) WITH NOWAIT;

BEGIN TRY
  BEGIN TRANSACTION;
  
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ Neuen EinzHist-Eintrag (Typ 3 - ausgeschieden) erstellen und in Temp-Table eintragen                                      ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    INSERT INTO EinzHist (EinzTeilID, Barcode, EinzHistTyp, [Status], EinzHistVon, KundenID, VsaID, TraegerID, TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, Ausdienst, AusdienstDat, WegGrundID, UserID_, AnlageUserID_)
    OUTPUT inserted.EinzTeilID, inserted.ID
    INTO @MapTable (EinzTeilID, EinzHistID)
    SELECT EinzTeilID, Barcode, CAST(3 AS int) AS EinzHistTyp, CAST('Y' AS varchar(2)) AS [Status], @curdatetime AS EinzHistVon, KundenID, VsaID, TraegerID, CAST(-1 AS int) AS TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, ISNULL(Ausdienst, @ausdienstweek) AS Ausdienst, ISNULL(AusdienstDat, CAST(@curdatetime AS date)) AS AusdienstDat, @weggrundid AS WegGrundID, @userid AS UserID_, @userid AS AnlageUserID_
    FROM #Cleanup;

    UPDATE #Cleanup SET EinzHistID_Schrott = [@MapTable].EinzHistID
    FROM @MapTable
    WHERE [@MapTable].EinzTeilID = #Cleanup.EinzTeilID;

    SELECT @msg = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss', N'de-AT') + N': Neuen EinzHist-Eintrag eingefügt';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ Alten Umlauf-Datensatz anpassen                                                                                           ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    UPDATE EinzHist SET [Status] = N'Y', WegGrundID = @weggrundid, Ausdienst = ISNULL(#Cleanup.Ausdienst, @ausdienstweek), AusdienstDat = ISNULL(#Cleanup.AusdienstDat, CAST(@curdatetime AS date)), AusdienstGrund = ISNULL(#Cleanup.AusdienstGrund, N'Z'), Einzug = ISNULL(EinzHist.Einzug, CAST(@curdatetime AS date)), EinzHistBis = @curdatetime, UserID_ = @userid
    FROM #Cleanup
    WHERE #Cleanup.EinzHistID = EinzHist.ID;

    SELECT @msg = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss', N'de-AT') + N': Alten EinzHist-Eintrage aktualisiert';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ EinzTeil-Datensatz anpassen                                                                                               ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    UPDATE EinzTeil SET [Status] = N'Z', CurrEinzHistID = [@MapTable].EinzHistID, LastScanTime = @curdatetime, LastActionsID = 7, ZielNrID = 19, WegGrundID = @weggrundid, WegDatum = CAST(@curdatetime AS date), UserID_ = @userid
    FROM #Cleanup
    JOIN @MapTable ON #Cleanup.EinzTeilID = [@MapTable].EinzTeilID
    WHERE #Cleanup.EinzTeilID = EinzTeil.ID

    SELECT @msg = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss', N'de-AT') + N': EinzTeil-Datensatz angepasst';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ Scans schreiben (Rückgabe und Schrott - jeweils auf alten Umlauf-Datensatz)                                               ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    INSERT INTO Scans (EinzHistID, EinzTeilID, [DateTime], ActionsID, ZielNrID, ArbPlatzID, TraegerID, VsaID, AnlageUserID_, UserID_)
    SELECT [#Cleanup].EinzHistID, [#Cleanup].EinzTeilID, @returntime, CAST(6 AS int) AS ActionsID, CAST(6 AS int) AS ZielNrID, @arbplatzid AS ArbPlatzID, #Cleanup.TraegerID, #Cleanup.VsaID, @userid AS AnlageUserID_, @userid AS UserID_
    FROM #Cleanup;

    INSERT INTO Scans (EinzHistID, EinzTeilID, [DateTime], ActionsID, ZielNrID, ArbPlatzID, TraegerID, VsaID, AnlageUserID_, UserID_)
    SELECT [#Cleanup].EinzHistID, [#Cleanup].EinzTeilID, @curdatetime, CAST(7 AS int) AS ActionsID, CAST(19 AS int) AS ZielNrID, @arbplatzid AS ArbPlatzID, #Cleanup.TraegerID, #Cleanup.VsaID, @userid AS AnlageUserID_, @userid AS UserID_
    FROM #Cleanup;

    SELECT @msg = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss', N'de-AT') + N': Scans geschrieben';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;
  
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

DROP TABLE #Cleanup;
GO

SET CONTEXT_INFO 0x0; /* AdvanTex-Trigger für RepQueue deaktivieren */
GO