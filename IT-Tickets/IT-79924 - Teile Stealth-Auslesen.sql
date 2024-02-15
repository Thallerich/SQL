DROP TABLE IF EXISTS #TeilAuslesen;
GO

CREATE TABLE #TeilAuslesen (
  EinzHistID int PRIMARY KEY CLUSTERED,
  EinzTeilID int
);

GO

INSERT INTO #TeilAuslesen (EinzHistID, EinzTeilID)
SELECT EinzHist.ID AS EinzHistID, EinzHist.EinzTeilID
FROM EinzHist
JOIN Kunden ON EinzHist.KundenID = Kunden.ID
JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
JOIN _IT79924 ON EinzHist.Barcode = _IT79924.Barcode AND Kunden.KdNr = _IT79924.KdNr AND Artikel.ArtikelNr = _IT79924.ArtikelNr
WHERE EinzHist.EinzTeilID = (SELECT EinzTeil.ID FROM EinzTeil WHERE EinzTeil.CurrEinzHistID = EinzHist.ID)
  AND EinzHist.[Status] BETWEEN N'Q' AND N'W'
  AND EinzHist.Einzug IS NULL
  AND ISNULL(EinzHist.Eingang1, N'2099-12-31') > ISNULL(EinzHist.Ausgang1, N'1980-01-01')
  AND EinzHist.EinzHistTyp = 1;

GO

DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE EinzHist SET Ausgang1 = N'2024-02-10', Ausgang2 = Ausgang1, Ausgang3 = Ausgang2
    WHERE ID IN (SELECT EinzHistID FROM #TeilAuslesen);

    INSERT INTO Scans (EinzHistID, EinzTeilID, [DateTime], ActionsID, ZielNrID, Menge, Info, AnlageUserID_, UserID_)
    SELECT #TeilAuslesen.EinzHistID, #TeilAuslesen.EinzTeilID, N'2024-02-10 12:00:00', 2, 2, -1, N'IT-79886 - Datenbereinigung Rückstandsliste - Auslesen ohne LS per Skript - THALLER Stefan', @UserID, @UserID
    FROM #TeilAuslesen;
  
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