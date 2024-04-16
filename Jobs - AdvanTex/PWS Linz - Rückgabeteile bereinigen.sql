/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ IT-81049 -- PWS-Rückgabeteile auf Schrott stellen                                                                         ++ */
/* ++ In Absprache mit Saffertmüller Larissa und Schal Christian umgesetzt                                                      ++ */
/* ++ Mit Release 9.90 nicht mehr nötig, da dann Bewohner-Teile nicht mehr auf Rückgabe gestellt werden können -> CR: 153648    ++ */
/* ++ Author: Stefan THALLER - 2024-04-16                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SET NOCOUNT ON;
SET CONTEXT_INFO 0x1; /* AdvanTex-Trigger für RepQueue deaktivieren */

DROP TABLE IF EXISTS #PWSCleanup;

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
  AusdienstGrund varchar(1)
);

CREATE NONCLUSTERED INDEX IX_PWSCleanup ON #PWSCleanup (EinzTeilID) WITH (DATA_COMPRESSION = PAGE);

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Teile entsprechend der Kriterien in Temp-Table holen                                                                      ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @kdgfid int = (SELECT KdGf.ID FROM KdGf WHERE KdGf.KurzBez = N'MED');
DECLARE @weggrundid int = 167; /* IT -> Schrott */
DECLARE @curdatetime datetime2 = GETDATE();
DECLARE @returntime datetime2 = DATEADD(millisecond, -10, @curdatetime);
DECLARE @ausdienstweek varchar(7) = (SELECT [Week].Woche FROM [Week] WHERE CAST(GETDATE() AS date) BETWEEN [Week].VonDat AND [Week].BisDat);
DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'JOB')
DECLARE @arbplatzid int = (SELECT ID FROM ArbPlatz WHERE ComputerName = HOST_NAME());

DECLARE @Hauptstandort TABLE (
  StandortID int,
  StandortKuerzel nchar(4) COLLATE Latin1_General_CS_AS
);

DECLARE @MapTable TABLE (
  EinzTeilID int,
  EinzHistID int
);

INSERT INTO @Hauptstandort (StandortKuerzel)
VALUES (N'WOEN'), (N'WOLI');

UPDATE @Hauptstandort SET StandortID = Standort.ID
FROM Standort
WHERE Standort.SuchCode = [@Hauptstandort].StandortKuerzel;

INSERT INTO #PWSCleanup (EinzHistID, EinzTeilID, Barcode, KundenID, VsaID, TraegerID, TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, Ausdienst, AusdienstDat, AusdienstGrund)
SELECT EinzHist.ID, EinzHist.EinzTeilID, EinzHist.Barcode, EinzHist.KundenID, EinzHist.VsaID, EinzHist.TraegerID, EinzHist.TraeArtiID, EinzHist.KdArtiID, EinzHist.ArtikelID, EinzHist.ArtGroeID, EinzHist.Ausdienst, EinzHist.AusdienstDat, EinzHist.AusdienstGrund
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
JOIN Eigentum ON KdArti.EigentumID = Eigentum.ID
WHERE Kunden.KdGFID = @kdgfid
  AND Kunden.StandortID IN (SELECT StandortID FROM @Hauptstandort)
  AND EinzTeil.AltenheimModus IN (1, 2)
  AND EinzHist.Status = N'W'
  AND Eigentum.RueckgabeBew = 0
  AND EinzHist.EinzHistTyp = 1
  AND EinzHist.TraeArtiID != -1;
  
BEGIN TRY
  BEGIN TRANSACTION;
  
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ Neuen EinzHist-Eintrag (Typ 3 - ausgeschieden) erstellen und in Temp-Table eintragen                                      ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    INSERT INTO EinzHist (EinzTeilID, Barcode, EinzHistTyp, [Status], EinzHistVon, KundenID, VsaID, TraegerID, TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, Ausdienst, AusdienstDat, WegGrundID, UserID_, AnlageUserID_)
    OUTPUT inserted.EinzTeilID, inserted.ID
    INTO @MapTable (EinzTeilID, EinzHistID)
    SELECT EinzTeilID, Barcode, CAST(3 AS int) AS EinzHistTyp, CAST('Y' AS varchar(2)) AS [Status], @curdatetime AS EinzHistVon, KundenID, VsaID, TraegerID, CAST(-1 AS int) AS TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, ISNULL(Ausdienst, @ausdienstweek) AS Ausdienst, ISNULL(AusdienstDat, CAST(@curdatetime AS date)) AS AusdienstDat, @weggrundid AS WegGrundID, @userid AS UserID_, @userid AS AnlageUserID_
    FROM #PWSCleanup;

    UPDATE #PWSCleanup SET EinzHistID_Schrott = [@MapTable].EinzHistID
    FROM @MapTable
    WHERE [@MapTable].EinzTeilID = #PWSCleanup.EinzTeilID;

    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ Alten Umlauf-Datensatz anpassen                                                                                           ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    UPDATE EinzHist SET [Status] = N'Y', WegGrundID = @weggrundid, Ausdienst = ISNULL(#PWSCleanup.Ausdienst, @ausdienstweek), AusdienstDat = ISNULL(#PWSCleanup.AusdienstDat, CAST(@curdatetime AS date)), AusdienstGrund = ISNULL(#PWSCleanup.AusdienstGrund, N'Z'), Einzug = ISNULL(EinzHist.Einzug, CAST(@curdatetime AS date)), EinzHistBis = @curdatetime, UserID_ = @userid
    FROM #PWSCleanup
    WHERE #PWSCleanup.EinzHistID = EinzHist.ID;

    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ EinzTeil-Datensatz anpassen                                                                                               ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    UPDATE EinzTeil SET [Status] = N'Z', CurrEinzHistID = [@MapTable].EinzHistID, LastScanTime = @curdatetime, LastActionsID = 7, ZielNrID = 19, WegGrundID = @weggrundid, WegDatum = CAST(@curdatetime AS date), UserID_ = @userid
    FROM #PWSCleanup
    JOIN @MapTable ON #PWSCleanup.EinzTeilID = [@MapTable].EinzTeilID
    WHERE #PWSCleanup.EinzTeilID = EinzTeil.ID;

    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ Scans schreiben (Rückgabe und Schrott - jeweils auf alten Umlauf-Datensatz)                                               ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    INSERT INTO Scans (EinzHistID, EinzTeilID, [DateTime], ActionsID, ZielNrID, ArbPlatzID, TraegerID, VsaID, AnlageUserID_, UserID_)
    SELECT [#PWSCleanup].EinzHistID, [#PWSCleanup].EinzTeilID, @returntime, CAST(6 AS int) AS ActionsID, CAST(6 AS int) AS ZielNrID, @arbplatzid AS ArbPlatzID, #PWSCleanup.TraegerID, #PWSCleanup.VsaID, @userid AS AnlageUserID_, @userid AS UserID_
    FROM #PWSCleanup;

    INSERT INTO Scans (EinzHistID, EinzTeilID, [DateTime], ActionsID, ZielNrID, ArbPlatzID, TraegerID, VsaID, AnlageUserID_, UserID_)
    SELECT [#PWSCleanup].EinzHistID, [#PWSCleanup].EinzTeilID, @curdatetime, CAST(7 AS int) AS ActionsID, CAST(19 AS int) AS ZielNrID, @arbplatzid AS ArbPlatzID, #PWSCleanup.TraegerID, #PWSCleanup.VsaID, @userid AS AnlageUserID_, @userid AS UserID_
    FROM #PWSCleanup;
  
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

DROP TABLE #PWSCleanup;