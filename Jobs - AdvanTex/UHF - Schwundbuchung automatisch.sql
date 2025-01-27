DECLARE @HalfYearAgo datetime = DATEADD(day, -250, GETDATE());
DECLARE @curdatetime datetime2 = GETDATE();
DECLARE @returntime datetime2 = DATEADD(millisecond, -10, @curdatetime);
DECLARE @userid int = (SELECT MitarbeiID FROM #AdvSession);
DECLARE @arbplatzid int = (SELECT ID FROM ArbPlatz WHERE ComputerName = HOST_NAME());
DECLARE @curweek nchar(7) = (SELECT [Week].Woche FROM [Week] WHERE CAST(GETDATE() AS date) BETWEEN [Week].VonDat AND [Week].BisDat);

DECLARE @KdNr AS TABLE (
  KdNr int
);

DECLARE @MapTable TABLE (
  EinzTeilID int,
  EinzHistID int
);

/* Die folgenden Kundennummern werden von diesem Skript automatisch Schwund-gebucht */
INSERT INTO @KdNr VALUES (6071), (7240), (9013), (15001), (15007), (18029), (19080), (20000), (20156), (23032), (23037), (23041), (23042), (23044), (24045), (242013), (245347), (246805), (248564), (2710498), (2710499), (10001671), (10001672), (10001770), (10001810), (10001816), (10003247);

DROP TABLE IF EXISTS #PoolSchwund;

CREATE TABLE #PoolSchwund (
  EinzHistID int,
  EinzHistID_Schwund int,
  EinzTeilID int,
  Barcode varchar(33) COLLATE Latin1_General_CS_AS,
  KundenID int,
  KdArtiID int,
  ArtikelID int,
  ArtGroeID int
);

INSERT INTO #PoolSchwund (EinzHistID, EinzTeilID, Barcode, ArtikelID, ArtGroeID)
SELECT EinzHist.ID, EinzHist.EinzTeilID, EinzHist.Barcode, EinzHist.ArtikelID, EinzHist.ArtGroeID
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN Vsa ON EinzTeil.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON EinzTeil.LastErsatzFuerKdArtiID = KdArti.ID
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
WHERE Kunden.KdNr IN (SELECT KdNr FROM @KdNr)
  AND EinzTeil.Status = N'Q'
  AND Bereich.Bereich != N'ST'
  AND EinzTeil.LastActionsID IN (2, 102, 120, 129, 130, 136, 137, 154, 173)
  AND EinzHist.PoolFkt = 1
  AND EinzHist.EinzHistTyp = 1
  AND EinzTeil.LastScanTime < @HalfYearAgo;

BEGIN TRY
  BEGIN TRANSACTION;
  
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ Neuen EinzHist-Eintrag (Typ 3 - ausgeschieden) erstellen und in Temp-Table eintragen                                      ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    INSERT INTO EinzHist (EinzTeilID, Barcode, EinzHistTyp, PoolFkt, [Status], EinzHistVon, ArtikelID, ArtGroeID, UserID_, AnlageUserID_)
    OUTPUT inserted.EinzTeilID, inserted.ID
    INTO @MapTable (EinzTeilID, EinzHistID)
    SELECT EinzTeilID, Barcode, CAST(3 AS int) AS EinzHistTyp, CAST(1 AS bit) AS PoolFkt, CAST('Z' AS varchar(2)) AS [Status], @curdatetime AS EinzHistVon, ArtikelID, ArtGroeID, @userid AS UserID_, @userid AS AnlageUserID_
    FROM #PoolSchwund;

    UPDATE #PoolSchwund SET EinzHistID_Schwund = [@MapTable].EinzHistID
    FROM @MapTable
    WHERE [@MapTable].EinzTeilID = #PoolSchwund.EinzTeilID;

    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ Alten Umlauf-Datensatz anpassen                                                                                           ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    UPDATE EinzHist SET EinzHistBis = @curdatetime, Abmeldung = IIF(EinzHist.Indienst IS NOT NULL, @curweek, NULL), AbmeldDat = IIF(EinzHist.Indienst IS NOT NULL, CAST(@curdatetime AS date), NULL), Ausdienst = IIF(EinzHist.Indienst IS NOT NULL, @curweek, NULL), AusdienstDat = IIF(EinzHist.Indienst IS NOT NULL, CAST(@curdatetime AS date), NULL), UserID_ = @userid
    FROM #PoolSchwund
    WHERE #PoolSchwund.EinzHistID = EinzHist.ID;

    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ EinzTeil-Datensatz anpassen                                                                                               ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    UPDATE EinzTeil SET [Status] = N'W', CurrEinzHistID = [@MapTable].EinzHistID, LastActionsID = 116, ZielNrID = -1, RechPoID = -2, UserID_ = @userid
    FROM #PoolSchwund
    JOIN @MapTable ON #PoolSchwund.EinzTeilID = [@MapTable].EinzTeilID
    WHERE #PoolSchwund.EinzTeilID = EinzTeil.ID

    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ Scans schreiben (Rückgabe und Schrott - jeweils auf alten Umlauf-Datensatz)                                               ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    INSERT INTO Scans (EinzHistID, EinzTeilID, [DateTime], ActionsID, ZielNrID, ArbPlatzID, AnlageUserID_, UserID_)
    SELECT [#PoolSchwund].EinzHistID, [#PoolSchwund].EinzTeilID, @returntime AS [DateTime], CAST(116 AS int) AS ActionsID, CAST(-1 AS int) AS ZielNrID, @arbplatzid AS ArbPlatzID, @userid AS AnlageUserID_, @userid AS UserID_
    FROM #PoolSchwund;

  
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

DROP TABLE #PoolSchwund;