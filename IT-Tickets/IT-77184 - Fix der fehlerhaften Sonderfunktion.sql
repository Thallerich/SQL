/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++                                                                                                                           ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #SteppCopy;
GO

CREATE TABLE #SteppCopy (
  EinzHistID int,
  EinzTeilID int,
  Code varchar(33) COLLATE Latin1_General_CS_AS,
  Code24 varchar(33) COLLATE Latin1_General_CS_AS,
  ArtikelID int,
  ArtGroeID int,
  Erstwoche char(7) COLLATE Latin1_General_CS_AS,
  AnzWaschImpr int,
  AlterInfo int,
  Erstdatum date,
  RuecklaufG int,
  PoolFkt bit
);

WITH SteppArtikel AS (
  SELECT Artikel.ID AS ArtikelID, ArtGroe.ID AS ArtGroeID
  FROM ArtGroe
  JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
  WHERE Artikel.ArtikelNr = N'192403100000'
    AND ArtGroe.Groesse = N'-'
)
INSERT INTO #SteppCopy (Code, Code24, ArtikelID, ArtGroeID, Erstwoche, AnzWaschImpr, AlterInfo, Erstdatum, RuecklaufG, PoolFkt)
SELECT EinzTeil.Code, LEFT(EinzTeil.Code, 24) AS Code24, SteppArtikel.ArtikelID, SteppArtikel.ArtGroeID, EinzTeil.Erstwoche, EinzTeil.AnzWaschImpr, EinzTeil.AlterInfo, EinzTeil.ErstDatum, EinzTeil.RuecklaufG, EinzHist.PoolFkt
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
CROSS JOIN SteppArtikel
WHERE EinzHist.EinzHistVon BETWEEN N'2024-02-13 10:00:00' AND N'2024-02-13 17:00:00'
  AND EinzHist.AnlageUserID_ = 9245;

DELETE FROM #SteppCopy
WHERE EXISTS (
  SELECT EinzTeil.*
  FROM EinzTeil
  WHERE EinzTeil.Code = #SteppCopy.Code24
);

RAISERROR(N'Start anlegen der neuen Teile', 0, 1) WITH NOWAIT;

BEGIN TRY
  BEGIN TRANSACTION;
  
    DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

    DECLARE @EinzTeilInsert TABLE (
      EinzTeilID int,
      Code varchar(33) COLLATE Latin1_General_CS_AS
    );

    DECLARE @EinzHistInsert TABLE (
      EinzHistID int,
      Code varchar(33) COLLATE Latin1_General_CS_AS
    );

    INSERT INTO EinzTeil (Code, [Status], ArtikelID, ArtGroeID, Erstwoche, AnzWaschImpr, AlterInfo, ErstDatum, RuecklaufG, UserID_, AnlageUserID_)
    OUTPUT inserted.ID, inserted.Code INTO @EinzTeilInsert (EinzTeilID, Code)
    SELECT Code24, N'Q', ArtikelID, ArtGroeID, Erstwoche, AnzWaschImpr, AlterInfo, Erstdatum, RuecklaufG, @userid, @userid
    FROM #SteppCopy;

    UPDATE #SteppCopy SET EinzTeilID = [@EinzTeilInsert].EinzTeilID
    FROM @EinzTeilInsert
    WHERE [@EinzTeilInsert].Code = #SteppCopy.Code24;

    INSERT INTO EinzHist (EinzTeilID, Barcode, EinzHistTyp, PoolFkt, [Status], EinzHistVon, EinzHistBis, ArtikelID, ArtGroeID, UserID_, AnlageUserID_)
    OUTPUT inserted.ID, inserted.Barcode INTO @EinzHistInsert (EinzHistID, Code)
    SELECT EinzTeilID, Code24, 1, 0, N'Q', GETDATE(), N'2099-12-31 23:59:59.000', ArtikelID, ArtGroeID, @userid, @userid
    FROM #SteppCopy;

    UPDATE #SteppCopy SET EinzHistID = [@EinzHistInsert].EinzHistID
    FROM @EinzHistInsert
    WHERE [@EinzHistInsert].Code = #SteppCopy.Code24;

    UPDATE EinzTeil SET CurrEinzHistID = #SteppCopy.EinzHistID
    FROM #SteppCopy
    WHERE #SteppCopy.EinzTeilID = EinzTeil.ID;
  
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