/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ ACHTUNG: unfertig - nicht verwenden - EINZHIST noch offen                                                                 ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ EINZTEIL                                                                                                                  ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #CompareSdcSoll;
DROP TABLE IF EXISTS #CompareSdcJoin;

GO

SELECT Daten.*
INTO #CompareSdcSoll
FROM (
  SELECT DISTINCT EinzTeil.ID
  FROM Vsa, StandBer, StBerSdc, EinzTeil, EinzHist, KdArti, KdBer
  WHERE EinzHist.EinzTeilID = EinzTeil.ID
    AND Vsa.StandKonID = StandBer.StandKonID
    AND EinzHist.VsaID = Vsa.ID
    AND EinzHist.KdArtiID = KdArti.ID
    AND KdArti.KdBerID = KdBer.ID
    AND KdBer.BereichID = StandBer.BereichID
    AND StandBer.ID = StBerSdc.StandBerID
    AND StBerSdc.Modus = 0
    AND StBerSdc.SdcDevID = 1
    AND EinzHist.Status >= N'M'
    AND EinzTeil.AltenheimModus = IIF(0 = 1, EinzTeil.AltenheimModus, 0)
  ) AS Daten;

SELECT Daten.*, CAST(0 AS bit) AS [issent]
INTO #CompareSdcJoin
FROM (
  SELECT COALESCE(t1.id, - 1) AS AdvID, COALESCE(t2.id, - 1) AS SdcID
  FROM #CompareSdcSoll AS t1
  FULL OUTER JOIN [SVATWMLESQL1.sal.co.at].[Salesianer_Lenzing_1].dbo.EinzTeil AS t2 ON (t1.id = t2.id)
) AS Daten;

GO

DECLARE @SendTable TABLE (
  ID int
);

DECLARE @msg nvarchar(max), @counter int = 0;

WHILE EXISTS (SELECT * FROM #CompareSdcJoin WHERE issent = 0 AND (AdvID < 0 OR SdcID < 0) AND NOT (AdvID < 0 AND SdcID < 0))
BEGIN

  DELETE FROM @SendTable;

  BEGIN TRY
    BEGIN TRANSACTION;

      INSERT INTO RepQueue ( Typ, TableName, TableID, ApplicationID, SdcDevID, Priority)
      OUTPUT inserted.TableID INTO @SendTable (ID)
      SELECT TOP (10000) IIF(AdvID > -1, 'INSERT', 'DELETE') AS Typ, 'EINZTEIL' AS Tablename, IIF(AdvID > -1, AdvID, SdcID) AS TableID, N'THALST (ADS)' AS ApplicationID, 1 AS SdcDevID, 9999 AS Priority
      FROM #CompareSdcJoin
      WHERE (AdvID < 0 OR SdcID < 0)
        AND NOT (AdvID < 0 AND SdcID < 0)
        AND issent = 0
        AND NOT EXISTS (SELECT RepQueue.* FROM RepQueue WHERE RepQueue.TableID = #CompareSdcJoin.AdvID AND RepQueue.TableName = N'EINZTEIL' AND RepQueue.SdcDevID = 1);

      SET @counter = @counter + @@ROWCOUNT;

      UPDATE #CompareSdcJoin SET issent = 1
      FROM @SendTable
      WHERE [@SendTable].ID = IIF(#CompareSdcJoin.AdvID > -1, AdvID, SdcID);

      SET @msg = FORMAT(@counter, N'N', N'de-AT') + N' rows prepared for replication!'
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
  END CATCH;

  WAITFOR DELAY '00:00:01';

  SELECT @msg = FORMAT((SELECT COUNT(*) FROM #CompareSdcJoin WHERE issent = 0 AND (AdvID < 0 OR SdcID < 0) AND NOT (AdvID < 0 AND SdcID < 0)), N'N', N'de-AT') + N' rows remaining';
  RAISERROR(@msg, 0, 1) WITH NOWAIT;

END;

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ EINZHIST                                                                                                                  ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #CompareSdcSoll;
DROP TABLE IF EXISTS #CompareSdcJoin;

GO

SELECT Daten.*
INTO #CompareSdcSoll
FROM (
  SELECT DISTINCT EinzHist.ID, CAST(IIF(EinzTeil.CurrEinzHistID = EinzHist.ID, 1, 0) AS bit) AS isinactive
  FROM Vsa, StandBer, StBerSdc, EinzTeil, EinzHist, KdArti, KdBer
  WHERE EinzHist.EinzTeilID = EinzTeil.ID
    AND Vsa.StandKonID = StandBer.StandKonID
    AND EinzHist.VsaID = Vsa.ID
    AND EinzHist.KdArtiID = KdArti.ID
    AND KdArti.KdBerID = KdBer.ID
    AND KdBer.BereichID = StandBer.BereichID
    AND StandBer.ID = StBerSdc.StandBerID
    AND EinzHist.Status >= N'M'
    AND (StBerSdc.Modus = 0 OR (EinzHist.Status > '5' AND EinzHist.Status < 'Q'))
    AND StBerSdc.SdcDevID = 1
    AND EinzTeil.AltenheimModus = IIF(0 = 1, EinzTeil.AltenheimModus, 0)
  ) AS Daten;

SELECT Daten.*, CAST(0 AS bit) AS [issent]
INTO #CompareSdcJoin
FROM (
  SELECT COALESCE(t1.id, - 1) AS AdvID, COALESCE(t2.id, - 1) AS SdcID
  FROM #CompareSdcSoll AS t1
  FULL OUTER JOIN [SVATWMLESQL1.sal.co.at].[Salesianer_Lenzing_1].dbo.EinzTeil AS t2 ON (t1.id = t2.id)
) AS Daten;

GO

DECLARE @SendTable TABLE (
  ID int
);

DECLARE @msg nvarchar(max), @counter int = 0;

WHILE EXISTS (SELECT * FROM #CompareSdcJoin WHERE issent = 0 AND (AdvID < 0 OR SdcID < 0) AND NOT (AdvID < 0 AND SdcID < 0))
BEGIN

  DELETE FROM @SendTable;

  BEGIN TRY
    BEGIN TRANSACTION;

      INSERT INTO RepQueue ( Typ, TableName, TableID, ApplicationID, SdcDevID, Priority)
      OUTPUT inserted.TableID INTO @SendTable (ID)
      SELECT TOP (10000) IIF(AdvID > -1, 'INSERT', 'DELETE') AS Typ, 'EINZTEIL' AS Tablename, IIF(AdvID > -1, AdvID, SdcID) AS TableID, N'THALST (ADS)' AS ApplicationID, 1 AS SdcDevID, 9999 AS Priority
      FROM #CompareSdcJoin
      WHERE (AdvID < 0 OR SdcID < 0)
        AND NOT (AdvID < 0 AND SdcID < 0)
        AND issent = 0
        AND NOT EXISTS (SELECT RepQueue.* FROM RepQueue WHERE RepQueue.TableID = #CompareSdcJoin.AdvID AND RepQueue.TableName = N'EINZTEIL' AND RepQueue.SdcDevID = 1);

      SET @counter = @counter + @@ROWCOUNT;

      UPDATE #CompareSdcJoin SET issent = 1
      FROM @SendTable
      WHERE [@SendTable].ID = IIF(#CompareSdcJoin.AdvID > -1, AdvID, SdcID);

      SET @msg = FORMAT(@counter, N'N', N'de-AT') + N' rows prepared for replication!'
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
  END CATCH;

  WAITFOR DELAY '00:00:01';

  SELECT @msg = FORMAT((SELECT COUNT(*) FROM #CompareSdcJoin WHERE issent = 0 AND (AdvID < 0 OR SdcID < 0) AND NOT (AdvID < 0 AND SdcID < 0)), N'N', N'de-AT') + N' rows remaining';
  RAISERROR(@msg, 0, 1) WITH NOWAIT;

END;

GO

-- SELECT * FROM RepQueue
-- TRUNCATE TABLE RepQueue