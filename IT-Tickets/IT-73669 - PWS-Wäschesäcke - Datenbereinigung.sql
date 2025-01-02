SET NOCOUNT ON;
SET XACT_ABORT ON;
SET CONTEXT_INFO 0x1; /* AdvanTex-Trigger für RepQueue deaktivieren */
GO

DROP TABLE IF EXISTS #PWSCleanup, #PWSCleanupProcess;
GO

CREATE TABLE #PWSCleanup (
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
  AusdienstGrund varchar(1),
  Processed bit DEFAULT 0
);

CREATE TABLE #PWSCleanupProcess (
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

CREATE NONCLUSTERED INDEX IX_PWSCleanup ON #PWSCleanup (EinzTeilID) WITH (DATA_COMPRESSION = PAGE);

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Teile entsprechend der Kriterien in Temp-Table holen                                                                      ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @cutoff date = N'2024-12-31';
DECLARE @weggrundid int = 167; /* IT -> Schrott */
DECLARE @curdatetime datetime2 = GETDATE();
DECLARE @returntime datetime2 = DATEADD(millisecond, -10, @curdatetime);
DECLARE @ausdienstweek varchar(7) = (SELECT [Week].Woche FROM [Week] WHERE CAST(GETDATE() AS date) BETWEEN [Week].VonDat AND [Week].BisDat);
DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST')
DECLARE @arbplatzid int = (SELECT ID FROM ArbPlatz WHERE ComputerName = HOST_NAME());
DECLARE @msg nvarchar(max);

DECLARE @Artikel TABLE (
  ArtikelID int,
  ArtikelNr nchar(15) COLLATE Latin1_General_CS_AS
);

DECLARE @MapTable TABLE (
  EinzTeilID int,
  EinzHistID int
);

SELECT @msg = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss', N'de-AT') + N': Alte Säcke laden';
RAISERROR(@msg, 0, 1) WITH NOWAIT;

INSERT INTO @Artikel (ArtikelID, ArtikelNr)
SELECT Artikel.ID, Artikel.ArtikelNr
FROM Artikel
WHERE Artikel.ArtGruID IN (SELECT ArtGru.ID FROM ArtGru WHERE ArtGru.Sack = 1);

INSERT INTO #PWSCleanup (EinzHistID, EinzTeilID, Barcode, KundenID, VsaID, TraegerID, TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, Ausdienst, AusdienstDat, AusdienstGrund)
SELECT EinzHist.ID, EinzHist.EinzTeilID, EinzHist.Barcode, EinzHist.KundenID, EinzHist.VsaID, EinzHist.TraegerID, EinzHist.TraeArtiID, EinzHist.KdArtiID, EinzHist.ArtikelID, EinzHist.ArtGroeID, EinzHist.Ausdienst, EinzHist.AusdienstDat, EinzHist.AusdienstGrund
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN Kunden ON EinzHist.KundenID = Kunden.ID
WHERE Kunden.ID IN (2936872, 2936841, 2936851, 2936839, 2936837, 2936843, 2936791, 2936792, 2936827, 2936795, 2936828, 2936797, 2936798, 2936799, 2936811, 2936819, 2936838, 2936834, 2936821, 2936836, 2936853, 2936854, 2936855, 2936635, 2935104, 2936257, 2936812, 2936866, 2935098, 2936915, 2936961, 2936946, 2936956, 2934730, 2936929, 2936963, 2936931, 2936964, 2936959, 2936923, 2936924, 2936925, 2936934, 2935102, 2936936, 2936933, 2936938, 2936980, 2936990, 2937026, 2936995, 2937017, 2939962, 2939963, 2941395, 2941423, 2941427, 2942451, 2942456, 2950921, 2951399, 2952800, 3736387, 3743169, 3743170)
  AND EinzHist.ArtikelID IN (SELECT ArtikelID FROM @Artikel)
  AND EinzTeil.AltenheimModus IN (1, 2)
  AND EinzHist.EinzHistTyp = 1
  AND EinzHist.[Status] IN (N'U', N'W')
  AND EinzHist.AbmeldDat <= @cutoff
  AND ISNULL(EinzHist.Ausgang1, CAST(N'1980-01-01' AS date)) <= @cutoff;

SELECT @msg = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss', N'de-AT') + N': Anzahl alter Säcke = ' + FORMAT(@@ROWCOUNT, N'N0', N'de-AT');
RAISERROR(@msg, 0, 1) WITH NOWAIT;

INSERT INTO #PWSCleanupProcess (EinzHistID, EinzTeilID, Barcode, KundenID, VsaID, TraegerID, TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, Ausdienst, AusdienstDat, AusdienstGrund)
SELECT TOP 100 EinzHistID, EinzTeilID, Barcode, KundenID, VsaID, TraegerID, TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, Ausdienst, AusdienstDat, AusdienstGrund
FROM #PWSCleanup
WHERE Processed = 0;

WHILE (SELECT COUNT(*) FROM #PWSCleanupProcess) > 0
BEGIN
  BEGIN TRY
    BEGIN TRANSACTION;

      SELECT @msg = N'----------------------------------------------------';
      RAISERROR(@msg, 0, 1) WITH NOWAIT;
    
      /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
      /* ++ Neuen EinzHist-Eintrag (Typ 3 - ausgeschieden) erstellen und in Temp-Table eintragen                                      ++ */
      /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

      INSERT INTO EinzHist (EinzTeilID, Barcode, EinzHistTyp, [Status], EinzHistVon, KundenID, VsaID, TraegerID, TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, Ausdienst, AusdienstDat, WegGrundID, UserID_, AnlageUserID_)
      OUTPUT inserted.EinzTeilID, inserted.ID
      INTO @MapTable (EinzTeilID, EinzHistID)
      SELECT EinzTeilID, Barcode, CAST(3 AS int) AS EinzHistTyp, CAST('Y' AS varchar(2)) AS [Status], @curdatetime AS EinzHistVon, KundenID, VsaID, TraegerID, CAST(-1 AS int) AS TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, ISNULL(Ausdienst, @ausdienstweek) AS Ausdienst, ISNULL(AusdienstDat, CAST(@curdatetime AS date)) AS AusdienstDat, @weggrundid AS WegGrundID, @userid AS UserID_, @userid AS AnlageUserID_
      FROM #PWSCleanupProcess;

      UPDATE #PWSCleanupProcess SET EinzHistID_Schrott = [@MapTable].EinzHistID
      FROM @MapTable
      WHERE [@MapTable].EinzTeilID = #PWSCleanupProcess.EinzTeilID;

      SELECT @msg = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss', N'de-AT') + N': Neuen EinzHist-Eintrag eingefügt';
      RAISERROR(@msg, 0, 1) WITH NOWAIT;

      /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
      /* ++ Alten Umlauf-Datensatz anpassen                                                                                           ++ */
      /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

      UPDATE EinzHist SET [Status] = N'Y', WegGrundID = @weggrundid, Ausdienst = ISNULL(#PWSCleanupProcess.Ausdienst, @ausdienstweek), AusdienstDat = ISNULL(#PWSCleanupProcess.AusdienstDat, CAST(@curdatetime AS date)), AusdienstGrund = ISNULL(#PWSCleanupProcess.AusdienstGrund, N'Z'), Einzug = ISNULL(EinzHist.Einzug, CAST(@curdatetime AS date)), EinzHistBis = @curdatetime, UserID_ = @userid
      FROM #PWSCleanupProcess
      WHERE #PWSCleanupProcess.EinzHistID = EinzHist.ID;

      SELECT @msg = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss', N'de-AT') + N': Alten EinzHist-Eintrage aktualisiert';
      RAISERROR(@msg, 0, 1) WITH NOWAIT;

      /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
      /* ++ EinzTeil-Datensatz anpassen                                                                                               ++ */
      /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

      UPDATE EinzTeil SET [Status] = N'Z', CurrEinzHistID = [@MapTable].EinzHistID, LastScanTime = @curdatetime, LastActionsID = 7, ZielNrID = 19, WegGrundID = @weggrundid, WegDatum = CAST(@curdatetime AS date), UserID_ = @userid
      FROM #PWSCleanupProcess
      JOIN @MapTable ON #PWSCleanupProcess.EinzTeilID = [@MapTable].EinzTeilID
      WHERE #PWSCleanupProcess.EinzTeilID = EinzTeil.ID

      SELECT @msg = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss', N'de-AT') + N': EinzTeil-Datensatz angepasst';
      RAISERROR(@msg, 0, 1) WITH NOWAIT;

      /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
      /* ++ Scans schreiben (Rückgabe und Schrott - jeweils auf alten Umlauf-Datensatz)                                               ++ */
      /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

      INSERT INTO Scans (EinzHistID, EinzTeilID, [DateTime], ActionsID, ZielNrID, ArbPlatzID, TraegerID, VsaID, AnlageUserID_, UserID_)
      SELECT [#PWSCleanupProcess].EinzHistID, [#PWSCleanupProcess].EinzTeilID, @returntime, CAST(6 AS int) AS ActionsID, CAST(6 AS int) AS ZielNrID, @arbplatzid AS ArbPlatzID, #PWSCleanupProcess.TraegerID, #PWSCleanupProcess.VsaID, @userid AS AnlageUserID_, @userid AS UserID_
      FROM #PWSCleanupProcess;

      INSERT INTO Scans (EinzHistID, EinzTeilID, [DateTime], ActionsID, ZielNrID, ArbPlatzID, TraegerID, VsaID, AnlageUserID_, UserID_)
      SELECT [#PWSCleanupProcess].EinzHistID, [#PWSCleanupProcess].EinzTeilID, @curdatetime, CAST(7 AS int) AS ActionsID, CAST(19 AS int) AS ZielNrID, @arbplatzid AS ArbPlatzID, #PWSCleanupProcess.TraegerID, #PWSCleanupProcess.VsaID, @userid AS AnlageUserID_, @userid AS UserID_
      FROM #PWSCleanupProcess;

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
    BREAK;
  END CATCH;

  UPDATE #PWSCleanup SET Processed = 1 WHERE EinzHistID IN (SELECT EinzHistID FROM #PWSCleanupProcess);
  
  DELETE FROM #PWSCleanupProcess;

  SELECT @msg = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss', N'de-AT') + N': Noch ' + FORMAT(COUNT(*), N'N0') + N' Säcke zu bearbeiten' FROM #PWSCleanup WHERE Processed = 0;
  RAISERROR(@msg, 0, 1) WITH NOWAIT;

  WAITFOR DELAY N'00:00:01';
  
  INSERT INTO #PWSCleanupProcess (EinzHistID, EinzTeilID, Barcode, KundenID, VsaID, TraegerID, TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, Ausdienst, AusdienstDat, AusdienstGrund)
  SELECT TOP 100 EinzHistID, EinzTeilID, Barcode, KundenID, VsaID, TraegerID, TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, Ausdienst, AusdienstDat, AusdienstGrund
  FROM #PWSCleanup
  WHERE Processed = 0;
END;

GO

DROP TABLE #PWSCleanup;
GO