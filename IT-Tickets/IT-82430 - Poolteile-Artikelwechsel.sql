DROP TABLE IF EXISTS #Artikeltausch, #EinzHistNeu;
GO

SELECT EinzHist.ID AS EinzHistID, EinzHist.EinzTeilID, EinzTeil.ArtGroeID, Artikel.ID AS ArtikelIDNeu, ArtGroeNeu.ID AS ArtGroeIDNeu
INTO #Artikeltausch
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN ArtGroe AS ArtGroeAlt ON EinzTeil.ArtGroeID = ArtGroeAlt.ID
JOIN _IT82430 ON [_IT82430].Code = EinzHist.Barcode
JOIN Artikel ON [_IT82430].ArtikelNrNeu = Artikel.ArtikelNr
JOIN ArtGroe AS ArtGroeNeu ON Artikel.ID = ArtGroeNeu.ArtikelID AND ArtGroeAlt.Groesse = ArtGroeNeu.Groesse
WHERE EinzHist.EinzHistTyp = 1
  AND EinzHist.Status < N'Z'
  AND EinzHist.PoolFkt = 1
  AND EinzTeil.ArtikelID != Artikel.ID;

SELECT EinzHist.*
INTO #EinzHistNeu
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN _IT82430 ON [_IT82430].Code = EinzHist.Barcode 
JOIN Artikel ON [_IT82430].ArtikelNrNeu = Artikel.ArtikelNr
WHERE EinzHist.EinzHistTyp = 1
  AND EinzHist.[Status] < N'Z'
  AND EinzHist.PoolFkt = 1
  AND EinzTeil.ArtikelID != Artikel.ID;

GO

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');
DECLARE @ArtikelwechselGrundID int = (SELECT TOP 1 WegGrund.ID FROM WegGrund WHERE WegGrund.ArtikelWechselPool = 1);
DECLARE @worktimestamp datetime2 = GETDATE();
DECLARE @today date = CAST(GETDATE() AS date);
DECLARE @curweek nchar(7) = (SELECT Week.Woche FROM [WEEK] WHERE GETDATE() BETWEEN Week.VonDat AND Week.BisDat);

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE EinzHist SET WegGrundID = @ArtikelwechselGrundID
    WHERE ID IN (SELECT EinzHistID FROM #Artikeltausch);

    UPDATE EinzTeil SET ArtGroeID = #Artikeltausch.ArtGroeIDNeu, ArtikelID = #Artikeltausch.ArtikelIDNeu
    FROM #Artikeltausch
    WHERE #Artikeltausch.EinzTeilID = EinzTeil.ID;
    
    UPDATE #EinzHistNeu SET ID = NEXT VALUE FOR NextID_EINZHIST, Barcode = EinzTeil.Code, RentomatChip = EinzTeil.Code2, SecondaryCode = EinzTeil.Code3, UebernahmeCode = EinzTeil.Code4, ArtikelID = EinzTeil.ArtikelID, ArtGroeID = EinzTeil.ArtGroeID, Archiv = 0, EinzHistVon = @worktimestamp, EinzHistBis = N'2099-12-31 23:59:59', EinzHistTyp = 1, PoolFkt = Bereich.UsesBkOpTeile, Indienst = IIF(#EinzHistNeu.Indienst IS NOT NULL, @curweek, NULL), IndienstDat = IIF(#EinzHistNeu.Indienst IS NOT NULL, @today, NULL), NachfolgeEinzHistID = -1, LagerOrtID = -1, Anlage_ = GETDATE(), AnlageUserID_ = @userid
    FROM EinzTeil
    JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
    JOIN Bereich ON Artikel.BereichID = Bereich.ID
    WHERE #EinzHistNeu.EinzTeilID = EinzTeil.ID;

    INSERT INTO EinzHist
    SELECT *
    FROM #EinzHistNeu;

    UPDATE EinzHist SET EinzHistBis = @worktimestamp, Ausdienst = IIF(EinzHist.Indienst IS NOT NULL, @curweek, NULL), AusdienstDat = IIF(EinzHist.Indienst IS NOT NULL, @today, NULL), Abmeldung = IIF(EinzHist.Indienst IS NOT NULL, @curweek, NULL), AbmeldDat = IIF(EinzHist.Indienst IS NOT NULL, @today, NULL)
    FROM #Artikeltausch
    WHERE #Artikeltausch.EinzHistID = EinzHist.ID;

    UPDATE EinzTeil SET CurrEinzHistID = #EinzHistNeu.ID
    FROM #EinzHistNeu
    WHERE EinzTeil.ID = #EinzHistNeu.EinzTeilID;
  
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

DROP TABLE #Artikeltausch, #EinzHistNeu;
GO