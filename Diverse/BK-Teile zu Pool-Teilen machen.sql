DROP TABLE IF EXISTS #MakePool;
GO

DECLARE @ArtiMap TABLE (
  ArtikelID_Alt int NOT NULL DEFAULT -1,
  ArtikelNr_Alt nchar(15) COLLATE Latin1_General_CS_AS NOT NULL,
  ArtikelID_Neu int NOT NULL DEFAULT -1,
  ArtikelNr_Neu nchar(15) COLLATE Latin1_General_CS_AS NOT NULL,
  ArtGroeID_Neu int NOT NULL DEFAULT -1
);

INSERT INTO @ArtiMap (ArtikelID_Alt, ArtikelNr_Alt, ArtikelID_Neu, ArtikelNr_Neu, ArtGroeID_Neu)
SELECT ArtikelAlt.ID AS ArtikelID_Alt, ArtikelAlt.ArtikelNr AS ArtikelNr_Alt, ArtikelNeu.ID AS ArtikelID_Neu, ArtikelNeu.ArtikelNr AS ArtikelNr_Neu, ArtGroe.ID AS ArtGroeID_Neu
FROM _IT100858
JOIN Artikel AS ArtikelAlt ON _IT100858.ArtikelNr = ArtikelAlt.ArtikelNr
JOIN Artikel AS ArtikelNeu ON _IT100858.ArtikelNr_Neu = ArtikelNeu.ArtikelNr
JOIN ArtGroe ON _IT100858.Groesse_Neu = ArtGroe.Groesse AND ArtikelNeu.ID = ArtGroe.ArtikelID;

SELECT EinzTeil.ID AS EinzTeilID, EinzHist.ID AS EinzHistID, EinzTeil.Code, EinzTeil.Code2, EinzTeil.Code3, EinzTeil.Code4, EinzTeil.[Status], ArtiMap.ArtikelID_Neu, ArtiMap.ArtGroeID_Neu
INTO #MakePool
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN Kunden ON EinzHist.KundenID = Kunden.ID
JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN @ArtiMap AS ArtiMap ON Artikel.ID = ArtiMap.ArtikelID_Alt
WHERE Kunden.KdNr = 100151
  AND EinzTeil.[Status] = 'Q'
  AND EinzHist.PoolFkt = 0
  AND LEN(EinzTeil.Code) = 24
  AND EinzTeil.Code = '300F4F573AD00180C9D5E358'
  AND EXISTS (
    SELECT Scans.*
    FROM Scans
    JOIN ZielNr ON Scans.ZielNrID = ZielNr.ID
    JOIN Standort ON ZielNr.ProduktionsID = Standort.ID
    WHERE Scans.EinzTeilID = EinzTeil.ID
      AND Standort.SuchCode LIKE N'WOE_'
      AND Scans.[DateTime] > DATEADD(day, -180, GETDATE())
  );

GO

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = UPPER(REPLACE(ORIGINAL_LOGIN(), N'SAL\', N'')));
DECLARE @curweek nchar(7) = (SELECT [Week].Woche FROM [Week] WHERE CAST(GETDATE() AS date) BETWEEN [Week].VonDat AND [Week].BisDat)

DECLARE @NewEinzHist TABLE (
  EinzTeilID int,
  EinzHistID int
);

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE EinzHist SET EinzHistBis = GETDATE(), Abmeldung = @curweek, AbmeldDat = CAST(GETDATE() AS date), Ausdienst = @curweek, AusdienstDat = CAST(GETDATE() AS date), AusdienstGrund = 'V', Einzug = CAST(GETDATE() AS date), UserID_ = @userid
    WHERE ID IN (SELECT EinzHistID FROM #MakePool);

    INSERT INTO EinzHist (EinzTeilID, Barcode, RentomatChip, SecondaryCode, UebernahmeCode, PoolFkt, [Status], EinzHistVon, ArtikelID, ArtGroeID, AnlageUserID_, UserID_)
    OUTPUT inserted.EinzTeilID, inserted.ID
    INTO @NewEinzHist (EinzTeilID, EinzHistID)
    SELECT #MakePool.EinzTeilID, #MakePool.Code AS Barcode, #MakePool.Code2 AS RentomatChip, #MakePool.Code3 AS SecondaryCode, #MakePool.Code4 AS UebernahmeCode, CAST(1 AS bit) AS PoolFkt, #MakePool.[Status], GETDATE() AS EinzHistVon, #MakePool.ArtikelID_Neu AS ArtikelID, #MakePool.ArtGroeID_Neu AS ArtGroeID, @userid AS AnlageUserID_, @userid AS UserID_
    FROM #MakePool;

    UPDATE EinzTeil SET ArtikelID = #MakePool.ArtikelID_Neu, ArtGroeID = #MakePool.ArtGroeID_Neu, CurrEinzHistID = NewEinzHist.EinzHistID, UserID_ = @userid
    FROM #MakePool
    JOIN @NewEinzHist AS NewEinzHist ON #MakePool.EinzTeilID = NewEinzHist.EinzTeilID
    WHERE #MakePool.EinzTeilID = EinzTeil.ID;
  
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