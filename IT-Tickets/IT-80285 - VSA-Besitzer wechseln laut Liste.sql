/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Source Table - Structure                                                                                                  ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  CREATE TABLE _IT83096 (
    Chipcode nvarchar(33) COLLATE Latin1_General_CS_AS NOT NULL,
    KdNr int,
    VsaBesitzer int,
    Schrott bit DEFAULT 0
  );

  SELECT * FROM _IT83096;

  TRUNCATE TABLE _IT83096;
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SET NOCOUNT ON;
GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ VSA-Besitzer ändern                                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #VsaOwnerChange;
GO

CREATE TABLE #VsaOwnerChange (
  EinzTeilID int,
  VsaOwnerID int
);

GO

DECLARE @msg nvarchar(max);

IF EXISTS (SELECT * FROM _IT83096 WHERE Schrott = 0)
BEGIN

  INSERT INTO #VsaOwnerChange (EinzTeilID, VsaOwnerID)
  SELECT EinzTeil.ID, VsaOwnerID = (
    SELECT Vsa.ID
    FROM Vsa
    JOIN Kunden ON Vsa.KundenID = Kunden.ID
    WHERE Kunden.KdNr = _IT83096.KdNr
      AND Vsa.VsaNr = _IT83096.VsaBesitzer
  )
  FROM EinzTeil
  JOIN _IT83096 ON EinzTeil.Code = _IT83096.Chipcode COLLATE Latin1_General_CS_AS
  WHERE _IT83096.Schrott = 0;

  SELECT @msg = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss', N'de-AT') + N': Besitzerwechsel - Anzahl Teile = ' + FORMAT(@@ROWCOUNT, N'N0', N'de-AT');
  RAISERROR(@msg, 0, 1) WITH NOWAIT;

  BEGIN TRY
    BEGIN TRANSACTION;
    
      UPDATE EinzTeil SET VsaOwnerID = #VsaOwnerChange.VsaOwnerID
      FROM #VsaOwnerChange
      WHERE #VsaOwnerChange.EinzTeilID = EinzTeil.ID
        AND #VsaOwnerChange.VsaOwnerID != EinzTeil.VsaOwnerID;
    
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

  SELECT @msg = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss', N'de-AT') + N': Besitzerwechsel - erledigt';
  RAISERROR(@msg, 0, 1) WITH NOWAIT;

END;

GO

DROP TABLE IF EXISTS #VsaOwnerChange;
GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Als Schrott markierte Einträge verschrotten                                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SET CONTEXT_INFO 0x1; /* AdvanTex-Trigger für RepQueue deaktivieren */
GO

DROP TABLE IF EXISTS #PoolSchrott;
GO

IF EXISTS (SELECT * FROM _IT83096 WHERE Schrott = 1)
BEGIN

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

  DECLARE @weggrundid int = 167; /* IT -> Schrott */
  DECLARE @curdatetime datetime2 = GETDATE();
  DECLARE @returntime datetime2 = DATEADD(millisecond, -10, @curdatetime);
  DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST')
  DECLARE @arbplatzid int = (SELECT ID FROM ArbPlatz WHERE ComputerName = HOST_NAME());
  DECLARE @msg nvarchar(max);

  DECLARE @MapTable TABLE (
    EinzTeilID int,
    EinzHistID int
  );

  SELECT @msg = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss', N'de-AT') + N': Schrott - Teile laden';
  RAISERROR(@msg, 0, 1) WITH NOWAIT;

  INSERT INTO #PoolSchrott (EinzHistID, EinzTeilID, Barcode, VsaID, ArtikelID, ArtGroeID, LastAnfPoID, RestwertInfo)
  SELECT EinzHist.ID, EinzHist.EinzTeilID, EinzHist.Barcode, EinzTeil.VsaID, EinzHist.ArtikelID, EinzHist.ArtGroeID, EinzHist.LastAnfPoID, EinzTeil.RestwertInfo
  FROM EinzTeil
  JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
  WHERE EinzTeil.Code IN (SELECT Chipcode FROM _IT83096 WHERE _IT83096.Schrott = 1)
    AND EinzTeil.[Status] != N'Z';

  SELECT @msg = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss', N'de-AT') + N': Schrott - Anzahl Teile = ' + FORMAT(@@ROWCOUNT, N'N0', N'de-AT');
  RAISERROR(@msg, 0, 1) WITH NOWAIT;

  BEGIN TRY
    BEGIN TRANSACTION;
    
      /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
      /* ++ Neuen EinzHist-Eintrag (Typ 3 - ausgeschieden) erstellen und in Temp-Table eintragen                                      ++ */
      /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

      INSERT INTO EinzHist (EinzTeilID, Barcode, EinzHistTyp, [Status], EinzHistVon, ArtikelID, ArtGroeID, LastAnfPoID, UserID_, AnlageUserID_)
      OUTPUT inserted.EinzTeilID, inserted.ID
      INTO @MapTable (EinzTeilID, EinzHistID)
      SELECT EinzTeilID, Barcode, CAST(3 AS int) AS EinzHistTyp, CAST('Y' AS varchar(2)) AS [Status], @curdatetime AS EinzHistVon, ArtikelID, ArtGroeID, LastAnfPoID, @userid AS UserID_, @userid AS AnlageUserID_
      FROM #PoolSchrott;

      UPDATE #PoolSchrott SET EinzHistID_Schrott = [@MapTable].EinzHistID
      FROM @MapTable
      WHERE [@MapTable].EinzTeilID = #PoolSchrott.EinzTeilID;

      SELECT @msg = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss', N'de-AT') + N': Schrott - Neuen EinzHist-Eintrag eingefügt';
      RAISERROR(@msg, 0, 1) WITH NOWAIT;

      /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
      /* ++ Alten Umlauf-Datensatz anpassen                                                                                           ++ */
      /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

      UPDATE EinzHist SET EinzHistBis = @curdatetime, UserID_ = @userid
      FROM #PoolSchrott
      WHERE #PoolSchrott.EinzHistID = EinzHist.ID;

      SELECT @msg = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss', N'de-AT') + N': Schrott - Alten EinzHist-Eintrage aktualisiert';
      RAISERROR(@msg, 0, 1) WITH NOWAIT;

      /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
      /* ++ EinzTeil-Datensatz anpassen                                                                                               ++ */
      /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

      UPDATE EinzTeil SET [Status] = N'Z', CurrEinzHistID = [@MapTable].EinzHistID, LastScanTime = @curdatetime, LastActionsID = 108, ZielNrID = 10000003, WegGrundID = @weggrundid, WegDatum = CAST(@curdatetime AS date), AusdRestwert = #PoolSchrott.RestwertInfo, UserID_ = @userid
      FROM #PoolSchrott
      JOIN @MapTable ON #PoolSchrott.EinzTeilID = [@MapTable].EinzTeilID
      WHERE #PoolSchrott.EinzTeilID = EinzTeil.ID

      SELECT @msg = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss', N'de-AT') + N': Schrott - EinzTeil-Datensatz angepasst';
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

      SELECT @msg = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss', N'de-AT') + N': Schrott - Scans geschrieben';
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

END;

GO

SET CONTEXT_INFO 0x0; /* AdvanTex-Trigger für RepQueue deaktivieren */
GO