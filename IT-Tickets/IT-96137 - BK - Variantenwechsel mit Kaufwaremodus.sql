SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

/* 
ALTER TABLE #EinzHist ADD EinzHistID int NOT NULL DEFAULT -1, TraeArtiID int NOT NULL DEFAULT -1, OldTraeArtiID int NOT NULL DEFAULT -1, NewKdArtiID int NOT NULL DEFAULT -1;
CREATE CLUSTERED INDEX IX_Barcode ON #EinzHist (Barcode) WITH (DATA_COMPRESSION = PAGE);
*/

DROP TABLE IF EXISTS #EinzHist;
GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ 0 = keine Kaufware                                                                                                        ++ */   
/* ++ 1 = Kaufware mit Waschauftrag                                                                                             ++ */
/* ++ 2 = Kaufware ohne Waschauftrag                                                                                            ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @KdNr int = 10002847;
DECLARE @ArtikelNr nvarchar(15) = N'L4FD';
DECLARE @AlteVariante nchar(4) = N'-';
DECLARE @NeueVariante nchar(4) = N'M';
DECLARE @Test bit = 0;
DECLARE @statusmsg nvarchar(max);
DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

IF @Test = 1
BEGIN
  SET @statusmsg = N'!!!!!!! TEST ONLY - no data changes will be saved !!!!!!!!';
  RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;
END;

SELECT EinzHist.ID AS EinzHistID, EinzHist.Barcode, EinzHist.TraegerID, EinzHist.KdArtiID, EinzHist.ArtGroeID, EinzHist.TraeArtiID AS OldTraeArtiID, -1 AS TraeArtiID, NewKdArti.ID AS NewKdArtiID, NewKdArti.KaufwareModus
INTO #EinzHist
FROM EinzHist
JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdArti AS NewKdArti ON NewKdArti.KundenID = Kunden.ID AND NewKdArti.ArtikelID = Artikel.ID
WHERE Kunden.KdNr = @KdNr
  AND Artikel.ArtikelNr = @ArtikelNr
  AND KdArti.Variante = @AlteVariante
  AND NewKdArti.Variante = @NeueVariante
  AND EinzHist.[Status] IN ('A', 'C', 'E', 'G', 'I', 'K', 'L', 'LM', 'M', 'N', 'O', 'Q', 'S')
  AND EinzHist.ID = (SELECT EinzTeil.CurrEinzHistID FROM EinzTeil WHERE EinzTeil.ID = EinzHist.EinzTeilID);

BEGIN TRY
  BEGIN TRANSACTION;
    
    SET @statusmsg = N'Create missing entries in TRAEARTI-table';
    RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;
  
    INSERT INTO TraeArti (VsaID, TraegerID, ArtGroeID, KdArtiID, KaufwareModus, UserID_, AnlageUserID_)
    SELECT TraeArti.VsaID, TraeArti.TraegerID, TraeArti.ArtGroeID, xMap.NewKdArtiID AS KdArtiID, xMap.KaufwareModus, @userid AS UserID_, @userid AS AnlageUserID_
    FROM TraeArti
    JOIN (
      SELECT DISTINCT #EinzHist.OldTraeArtiID, #EinzHist.NewKdArtiID, #EinzHist.KaufwareModus
      FROM #EinzHist
      WHERE #EinzHist.NewKdArtiID > 0
    ) AS xMap ON xMap.OldTraeArtiID = TraeArti.ID
    WHERE NOT EXISTS (
      SELECT NewTraeArti.*
      FROM TraeArti AS NewTraeArti
      WHERE NewTraeArti.TraegerID = TraeArti.TraegerID
        AND NewTraeArti.KdArtiID = xMap.NewKdArtiID
        AND NewTraeArti.ArtGroeID = TraeArti.ArtGroeID
    );

    SET @statusmsg = N'Done - ' + CAST(@@ROWCOUNT AS nvarchar) + N' rows affected!';
    RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

    SET @statusmsg = N'Mapping new entries into work table';
    RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

    UPDATE #EinzHist SET TraeArtiID = TraeArti.ID
    FROM TraeArti
    JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
    JOIN (
      SELECT DISTINCT #EinzHist.OldTraeArtiID, #EinzHist.NewKdArtiID
      FROM #EinzHist
      WHERE #EinzHist.NewKdArtiID > 0
    ) AS xMap ON xMap.NewKdArtiID = KdArti.ID
    JOIN TraeArti AS OldTraeArti ON xMap.OldTraeArtiID = OldTraeArti.ID
    WHERE OldTraeArti.TraegerID = TraeArti.TraegerID
      AND OldTraeArti.ArtGroeID = TraeArti.ArtGroeID
      AND xMap.NewKdArtiID = TraeArti.KdArtiID
      AND OldTraeArti.ID = #EinzHist.OldTraeArtiID;

    SET @statusmsg = N'Updating entries in EINZHIST-table to use new variant and mode';
    RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

    UPDATE EinzHist SET TraeArtiID = xMap.TraeArtiID, KdArtiID = xMap.NewKdArtiID, KaufwareModus = xMap.KaufwareModus, UserID_ = @userid
    FROM #EinzHist AS xMap
    WHERE xMap.EinzHistID = EinzHist.ID
      AND xMap.TraeArtiID > 0;

    SET @statusmsg = N'Done - ' + CAST(@@ROWCOUNT AS nvarchar) + N' rows affected!';
    RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;
  
  IF @Test = 1
  BEGIN
    ROLLBACK;
    SET @statusmsg = N'!!!!!!! TEST done - rolled back all changes !!!!!!!!'
    RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;
  END
  ELSE
  BEGIN
    COMMIT;
  END;
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

SELECT * FROM #EinzHist WHERE TraeArtiID < 0;

GO