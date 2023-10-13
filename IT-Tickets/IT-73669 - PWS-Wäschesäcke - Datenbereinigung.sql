DROP TABLE IF EXISTS #PWSSchrott;
GO

CREATE TABLE #PWSCleanup (
  EinzHistID int,
  EinzHistID_Schrott int,
  EinzTeilID int,
  Barcode varchar(33) COLLATE Latin1_General_CS_AS,
  KundenID int,
  VsaID int,
  TraegerID int,
  TraeArtiID int,
  KdArtiID int,
  ArtikelID int,
  ArtGroeID int
);

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Teile entsprechend der Kriterien in Temp-Table holen                                                                      ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @cutoff date = N'2022-12-31';
DECLARE @kdgfid int = (SELECT KdGf.ID FROM KdGf WHERE KdGf.KurzBez = N'MED');

DECLARE @Hauptstandort TABLE (
  StandortID int,
  StandortKuerzel nchar(4) COLLATE Latin1_General_CS_AS
);

DECLARE @Artikel TABLE (
  ArtikelID int,
  ArtikelNr nchar(15) COLLATE Latin1_General_CS_AS
);

INSERT INTO @Hauptstandort (StandortKuerzel)
VALUES (N'WOEN'), (N'WOLI');

UPDATE @Hauptstandort SET StandortID = Standort.ID
FROM Standort
WHERE Standort.SuchCode = [@Hauptstandort].StandortKuerzel;

INSERT INTO @Artikel (ArtikelNr)
VALUES (N'1800000605_1'), (N'180000000003'), (N'180000000001'), (N'180000000002'), (N'180000000004');

UPDATE @Artikel SET ArtikelID = Artikel.ID
FROM Artikel
WHERE Artikel.ArtikelNr = [@Artikel].ArtikelNr;

INSERT INTO #PWSCleanup (EinzHistID, EinzTeilID, Barcode, KundenID, VsaID, TraegerID, TraeArtiID, KdArtiID, ArtikelID, ArtGroeID)
SELECT EinzHist.ID, EinzHist.EinzTeilID, EinzHist.Barcode, EinzHist.KundenID, EinzHist.VsaID, EinzHist.TraegerID, EinzHist.TraeArtiID, EinzHist.KdArtiID, EinzHist.ArtikelID, EinzHist.ArtGroeID
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN Kunden ON EinzHist.KundenID = Kunden.ID
WHERE Kunden.KdGFID = @kdgfid
  AND Kunden.StandortID IN (SELECT StandortID FROM @Hauptstandort)
  AND EinzHist.ArtikelID IN (SELECT ArtikelID FROM @Artikel)
  AND EinzTeil.AltenheimModus = 1
  AND EinzHist.EinzHistTyp = 1
  AND EinzHist.[Status] IN (N'U', N'W')
  AND EinzHist.AbmeldDat <= @cutoff
  AND ISNULL(EinzHist.Ausgang1, CAST(N'1980-01-01' AS date)) <= @cutoff;

GO

DECLARE @weggrundid int = 167; /* IT -> Schrott */
DECLARE @ausdienstweek varchar(7) = (SELECT [Week].Woche FROM [Week] WHERE CAST(GETDATE() AS date) BETWEEN [Week].VonDat AND [Week].BisDat);
DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

DECLARE @MapTable TABLE (
  EinzTeilID int,
  EinzHistID int
);

BEGIN TRY
  BEGIN TRANSACTION;
  
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ Neuen EinzHist-Eintrag (Typ 3 - ausgeschieden) erstellen und in Temp-Table eintragen                                      ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    INSERT INTO EinzHist (EinzTeilID, Barcode, EinzHistTyp, [Status], EinzHistVon, IsCurrEinzHist, KundenID, VsaID, TraegerID, TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, Ausdienst, AusdienstDat, WegGrundID, UserID_, AnlageUserID_)
    OUTPUT inserted.EinzTeilID, inserted.ID
    INTO @MapTable (EinzTeilID, EinzHistID)
    SELECT EinzTeilID, Barcode, CAST(3 AS int) AS EinzHistTyp, CAST('Y' AS varchar(2)) AS [Status], GETDATE() AS EinzHistVon, CAST(1 AS bit) AS IsCurrEinzHist, KundenID, VsaID, TraegerID, CAST(-1 AS int) AS TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, @ausdienstweek AS Ausdienst, CAST(GETDATE() AS date) AS AusdienstDat, @weggrundid AS WegGrundID, @userid AS UserID_, @userid AS AnlageUserID_
    FROM #PWSCleanup;

    UPDATE #PWSCleanup SET EinzHistID_Schrott = [@MapTable].EinzHistID
    FROM @MapTable
    WHERE [@MapTable].EinzTeilID = #PWSCleanup.EinzTeilID;

    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ Alten Umlauf-Datensatz anpassen                                                                                           ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */



    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ EinzTeil-Datensatz anpassen                                                                                               ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */



    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ Scans schreiben (Rückgabe und Schrott - jeweils auf alten Umlauf-Datensatz)                                               ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */


  
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

DROP TABLE #PWSCleanup;
GO