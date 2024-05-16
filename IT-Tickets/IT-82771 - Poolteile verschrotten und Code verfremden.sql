SET NOCOUNT ON;
SET CONTEXT_INFO 0x1; /* AdvanTex-Trigger für RepQueue deaktivieren */
GO

DROP TABLE IF EXISTS #PoolSchrott;
GO

CREATE TABLE #PoolSchrott (
  EinzHistID int PRIMARY KEY CLUSTERED,
  EinzHistID_Schrott int,
  EinzTeilID int,
  Barcode varchar(33) COLLATE Latin1_General_CS_AS,
  VsaID int,
  KdArtiID int,
  ArtikelID int,
  ArtGroeID int,
  LastAnfPoID int,
  RestwertInfo money
);

CREATE NONCLUSTERED INDEX IX_PoolSchrott ON #PoolSchrott (EinzTeilID) WITH (DATA_COMPRESSION = PAGE);

GO

DECLARE @weggrundid int = 167; /* IT -> Schrott */
DECLARE @curdatetime datetime2 = GETDATE();
DECLARE @returntime datetime2 = DATEADD(millisecond, -10, @curdatetime);
DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST')
DECLARE @arbplatzid int = (SELECT ID FROM ArbPlatz WHERE ComputerName = HOST_NAME());
DECLARE @msg nvarchar(max);

DECLARE @Teile TABLE (
  Chipcode nvarchar(33) COLLATE Latin1_General_CS_AS
);

DECLARE @MapTable TABLE (
  EinzTeilID int,
  EinzHistID int
);

INSERT INTO @Teile
VALUES (N'300F4F573AD001804EEF3EBA'), (N'300F4F573AD001804EEF410F'), (N'300F4F573AD001804EEF4190'), (N'300F4F573AD001804EEF41A6'), (N'300F4F573AD001804EF14F72'), (N'300F4F573AD001804EF45781'), (N'300F4F573AD001804EF45C95'), (N'300F4F573AD001804EF4601C'), (N'300F4F573AD001804EF473BD'), (N'300F4F573AD001805033EC2D'), (N'300F4F573AD001824EEC888E'), (N'300F4F573AD001824EEC8C06'), (N'300F4F573AD001824EEC8CCC'), (N'300F4F573AD001824EECBAFC'), (N'300F4F573AD001824EECBAFD'), (N'300F4F573AD001824EECBB3E'), (N'300F4F573AD001824EECBBBB'), (N'300F4F573AD001824EECBC5A'), (N'300F4F573AD001824EECBC63'), (N'300F4F573AD001824EECBFA4'), (N'300F4F573AD001824EEECE06'), (N'300F4F573AD001824EF180F9'), (N'300F4F573AD001824EF18144'), (N'300F4F573AD001824EF18C26'), (N'300F4F573AD001824EF18EDD'), (N'300F4F573AD001824EF191C5'), (N'300F4F573AD001824EF19250'), (N'300F4F573AD001824EF194FF'), (N'300F4F573AD001824EF19513'), (N'300F4F573AD001824EF195B1'), (N'300F4F573AD001824EF195C4'), (N'300F4F573AD001824EF195C9'), (N'300F4F573AD001824EF19654'), (N'300F4F573AD001824EF42B52'), (N'300F4F573AD001824EF42B90'), (N'300F4F573AD0018250323D39'), (N'300F4F573AD00182503721B1'), (N'300F4F573AD0018250372215'), (N'300F4F573AD001C08D46D812'), (N'303445D6204477C400001A98'), (N'303445D6204477C4000022B9'), (N'303445D6204477C4000023F2');

SELECT @msg = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss', N'de-AT') + N': Zu verschrottende Teile laden';
RAISERROR(@msg, 0, 1) WITH NOWAIT;

INSERT INTO #PoolSchrott (EinzHistID, EinzTeilID, Barcode, VsaID, ArtikelID, ArtGroeID, LastAnfPoID, RestwertInfo)
SELECT EinzHist.ID, EinzHist.EinzTeilID, EinzHist.Barcode, EinzTeil.VsaID, EinzHist.ArtikelID, EinzHist.ArtGroeID, EinzHist.LastAnfPoID, EinzTeil.RestwertInfo
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
WHERE EinzTeil.Code IN (SELECT Chipcode FROM @Teile)
  AND EinzTeil.[Status] != N'Z';

SELECT @msg = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss', N'de-AT') + N': Anzahl Teile = ' + FORMAT(@@ROWCOUNT, N'N0', N'de-AT');
RAISERROR(@msg, 0, 1) WITH NOWAIT;

BEGIN TRY
  BEGIN TRANSACTION;
  
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ Neuen EinzHist-Eintrag (Typ 3 - ausgeschieden) erstellen und in Temp-Table eintragen                                      ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    INSERT INTO EinzHist (EinzTeilID, Barcode, EinzHistTyp, [Status], EinzHistVon, ArtikelID, ArtGroeID, LastAnfPoID, UserID_, AnlageUserID_)
    OUTPUT inserted.EinzTeilID, inserted.ID
    INTO @MapTable (EinzTeilID, EinzHistID)
    SELECT EinzTeilID, CONCAT(Barcode, N'*WEG') AS Barcode, CAST(3 AS int) AS EinzHistTyp, CAST('Y' AS varchar(2)) AS [Status], @curdatetime AS EinzHistVon, ArtikelID, ArtGroeID, LastAnfPoID, @userid AS UserID_, @userid AS AnlageUserID_
    FROM #PoolSchrott;

    UPDATE #PoolSchrott SET EinzHistID_Schrott = [@MapTable].EinzHistID
    FROM @MapTable
    WHERE [@MapTable].EinzTeilID = #PoolSchrott.EinzTeilID;

    SELECT @msg = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss', N'de-AT') + N': Neuen EinzHist-Eintrag eingefügt';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ Alten Umlauf-Datensatz anpassen                                                                                           ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    UPDATE EinzHist SET Barcode = CONCAT(EinzHist.Barcode, N'*WEG'), EinzHistBis = @curdatetime, UserID_ = @userid
    FROM #PoolSchrott
    WHERE #PoolSchrott.EinzHistID = EinzHist.ID;

    SELECT @msg = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss', N'de-AT') + N': Alten EinzHist-Eintrage aktualisiert';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ EinzTeil-Datensatz anpassen                                                                                               ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    UPDATE EinzTeil SET Code = CONCAT(Code, N'*WEG'), [Status] = N'Z', CurrEinzHistID = [@MapTable].EinzHistID, LastScanTime = @curdatetime, LastActionsID = 108, ZielNrID = 10000003, WegGrundID = @weggrundid, WegDatum = CAST(@curdatetime AS date), AusdRestwert = #PoolSchrott.RestwertInfo, UserID_ = @userid
    FROM #PoolSchrott
    JOIN @MapTable ON #PoolSchrott.EinzTeilID = [@MapTable].EinzTeilID
    WHERE #PoolSchrott.EinzTeilID = EinzTeil.ID

    SELECT @msg = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss', N'de-AT') + N': EinzTeil-Datensatz angepasst';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ Scans schreiben (Rückgabe und Schrott - jeweils auf alten Umlauf-Datensatz)                                               ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    INSERT INTO Scans (EinzHistID, EinzTeilID, [DateTime], ActionsID, ZielNrID, ArbPlatzID, VsaID, AnlageUserID_, UserID_)
    SELECT [#PoolSchrott].EinzHistID, [#PoolSchrott].EinzTeilID, @returntime, CAST(100 AS int) AS ActionsID, CAST(10000001 AS int) AS ZielNrID, @arbplatzid AS ArbPlatzID, #PoolSchrott.VsaID, @userid AS AnlageUserID_, @userid AS UserID_
    FROM #PoolSchrott;

    INSERT INTO Scans (EinzHistID, EinzTeilID, [DateTime], ActionsID, ZielNrID, ArbPlatzID, GrundID, AnlageUserID_, UserID_)
    SELECT [#PoolSchrott].EinzHistID, [#PoolSchrott].EinzTeilID, @curdatetime, CAST(108 AS int) AS ActionsID, CAST(10000003 AS int) AS ZielNrID, @arbplatzid AS ArbPlatzID, @weggrundid AS GrundID, @userid AS AnlageUserID_, @userid AS UserID_
    FROM #PoolSchrott;

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