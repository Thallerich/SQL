DROP TABLE IF EXISTS #PoolSchwund;
GO

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

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Teile laut Excel in Temp-Table holen                                                                      ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

INSERT INTO #PoolSchwund (EinzHistID, EinzTeilID, Barcode, ArtikelID, ArtGroeID)
SELECT EinzHist.ID, EinzHist.EinzTeilID, EinzHist.Barcode, EinzHist.ArtikelID, EinzHist.ArtGroeID
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN Vsa ON EinzTeil.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN _Poolschwund ON _Poolschwund.Barcode = EinzTeil.Code AND _Poolschwund.KdNr = Kunden.KdNr
WHERE EinzTeil.[Status] < N'W';

GO

DECLARE @curdatetime datetime2 = GETDATE();
DECLARE @returntime datetime2 = DATEADD(millisecond, -10, @curdatetime);
DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST')
DECLARE @arbplatzid int = (SELECT ID FROM ArbPlatz WHERE ComputerName = HOST_NAME());

DECLARE @MapTable TABLE (
  EinzTeilID int,
  EinzHistID int
);

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

    UPDATE EinzHist SET EinzHistBis = @curdatetime, UserID_ = @userid
    FROM #PoolSchwund
    WHERE #PoolSchwund.EinzHistID = EinzHist.ID;

    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ EinzTeil-Datensatz anpassen                                                                                               ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    UPDATE EinzTeil SET [Status] = N'W', CurrEinzHistID = [@MapTable].EinzHistID, LastActionsID = 116, ZielNrID = 10000105, RechPoID = -2, UserID_ = @userid
    FROM #PoolSchwund
    JOIN @MapTable ON #PoolSchwund.EinzTeilID = [@MapTable].EinzTeilID
    WHERE #PoolSchwund.EinzTeilID = EinzTeil.ID

    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ Scans schreiben (Rückgabe und Schrott - jeweils auf alten Umlauf-Datensatz)                                               ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    INSERT INTO Scans (EinzHistID, EinzTeilID, [DateTime], ActionsID, ZielNrID, ArbPlatzID, AnlageUserID_, UserID_)
    SELECT [#PoolSchwund].EinzHistID, [#PoolSchwund].EinzTeilID, @returntime AS [DateTime], CAST(116 AS int) AS ActionsID, CAST(10000105 AS int) AS ZielNrID, @arbplatzid AS ArbPlatzID, @userid AS AnlageUserID_, @userid AS UserID_
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


GO

DROP TABLE #PoolSchwund;
GO

/*
TRUNCATE TABLE _Poolschwund;
*/