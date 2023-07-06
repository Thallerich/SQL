/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Die Pool-Teile, die einen neuen Barcode erhalten sollen,                                   ++ */
/* ++ um zukünftig vom Poolteil zum BK-Teil gewandelt werden zu können                           ++ */
/* ++ um über die Sortieranlage ausgelesen werden zu können                                      ++ */
/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #PoolTeilToBK;
DROP TABLE IF EXISTS #BKTeileBarcodeVergabe;
DROP TABLE IF EXISTS #ExistierBereits;

CREATE TABLE #PoolTeilToBK (
  EinzHistID int,
  EinzTeilID int,
  Barcode nvarchar(33) COLLATE Latin1_General_CS_AS,
  NeuBarcode nvarchar(33) COLLATE Latin1_General_CS_AS
);

CREATE CLUSTERED INDEX #IX_PoolTeilToBK ON #PoolTeilToBK (EinzHistID, EinzTeilID);

INSERT INTO #PoolTeilToBK (EinzHistID, EinzTeilID, Barcode)
SELECT EinzHist.ID AS EinzHistID, EinzHist.EinzTeilID, EinzHist.Barcode
FROM EinzHist
JOIN EinzTeil ON EinzHist.EinzTeilID = EinzTeil.ID
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
WHERE Artikel.ArtikelNr IN ('U10','U11','U12','U31','U32','U33','U34','U37','U41','U42','U4K','U4M','U4N','U51','U5K','U5N','U71','U82','U83','U84','U86','U88','U8B','U8R','U8W','U91','U9N','UH1','UH2','UJ8')
  AND EinzTeil.Code2 IS NULL
  AND EinzHist.RentomatChip IS NULL
  AND EinzTeil.LastActionsID NOT IN (108, 116) /* Verschrotte und verschwundene Teile ausschließen -- 108 OP Schrott, 116 OP Schwund */
  AND EinzHist.[Status] BETWEEN N'M' AND N'W';

DELETE FROM #PoolTeilToBK WHERE LEN(Barcode) != 24;

CREATE TABLE #BKTeileBarcodeVergabe (
  EinzHistID int PRIMARY KEY CLUSTERED,
  Barcode nvarchar(33) COLLATE Latin1_General_CS_AS,
  BarcodeNum int
);
 
/* Prüfziffer berechnen */
INSERT INTO #BKTeileBarcodeVergabe (EinzHistID, Barcode, BarcodeNum)
SELECT #PoolTeilToBK.EinzHistID, NEXT VALUE FOR NextID_BARCODENR AS Barcode, BarcodeNum =
  IIF((LEN(#PoolTeilToBK.Barcode) >= 1) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,1,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,1,1) AS int) * 3, 0) +
  IIF((LEN(#PoolTeilToBK.Barcode) >= 2) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,2,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,2,1) AS int) * 1, 0) +
  IIF((LEN(#PoolTeilToBK.Barcode) >= 3) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,3,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,3,1) AS int) * 3, 0) +
  IIF((LEN(#PoolTeilToBK.Barcode) >= 4) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,4,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,4,1) AS int) * 1, 0) +
  IIF((LEN(#PoolTeilToBK.Barcode) >= 5) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,5,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,5,1) AS int) * 3, 0) +
  IIF((LEN(#PoolTeilToBK.Barcode) >= 6) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,6,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,6,1) AS int) * 1, 0) +
  IIF((LEN(#PoolTeilToBK.Barcode) >= 7) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,7,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,7,1) AS int) * 3, 0) +
  IIF((LEN(#PoolTeilToBK.Barcode) >= 8) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,8,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,8,1) AS int) * 1, 0) +
  IIF((LEN(#PoolTeilToBK.Barcode) >= 9) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,9,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,9,1) AS int) * 3, 0) +
  IIF((LEN(#PoolTeilToBK.Barcode) >= 10) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,10,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,10,1) AS int) * 1, 0) +
  IIF((LEN(#PoolTeilToBK.Barcode) >= 11) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,11,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,11,1) AS int) * 3, 0) +
  IIF((LEN(#PoolTeilToBK.Barcode) >= 12) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,12,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,12,1) AS int) * 1, 0) +
  IIF((LEN(#PoolTeilToBK.Barcode) >= 13) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,13,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,13,1) AS int) * 3, 0) +
  IIF((LEN(#PoolTeilToBK.Barcode) >= 14) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,14,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,14,1) AS int) * 1, 0) +
  IIF((LEN(#PoolTeilToBK.Barcode) >= 15) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,15,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,15,1) AS int) * 3, 0) +
  IIF((LEN(#PoolTeilToBK.Barcode) >= 16) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,16,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,16,1) AS int) * 1, 0) +
  IIF((LEN(#PoolTeilToBK.Barcode) >= 17) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,17,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,17,1) AS int) * 3, 0) +
  IIF((LEN(#PoolTeilToBK.Barcode) >= 18) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,18,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,18,1) AS int) * 1, 0) +
  IIF((LEN(#PoolTeilToBK.Barcode) >= 19) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,19,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,19,1) AS int) * 3, 0) +
  IIF((LEN(#PoolTeilToBK.Barcode) >= 20) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,20,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,20,1) AS int) * 1, 0) +
  IIF((LEN(#PoolTeilToBK.Barcode) >= 21) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,21,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,21,1) AS int) * 3, 0) +
  IIF((LEN(#PoolTeilToBK.Barcode) >= 22) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,22,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,22,1) AS int) * 1, 0) +
  IIF((LEN(#PoolTeilToBK.Barcode) >= 23) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,23,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,23,1) AS int) * 3, 0) +
  IIF((LEN(#PoolTeilToBK.Barcode) >= 24) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,24,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,24,1) AS int) * 1, 0) +
  IIF((LEN(#PoolTeilToBK.Barcode) >= 25) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,25,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,25,1) AS int) * 3, 0) +
  IIF((LEN(#PoolTeilToBK.Barcode) >= 26) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,26,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,26,1) AS int) * 1, 0) +
  IIF((LEN(#PoolTeilToBK.Barcode) >= 27) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,27,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,27,1) AS int) * 3, 0) +
  IIF((LEN(#PoolTeilToBK.Barcode) >= 28) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,28,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,28,1) AS int) * 1, 0) +
  IIF((LEN(#PoolTeilToBK.Barcode) >= 29) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,29,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,29,1) AS int) * 3, 0) +
  IIF((LEN(#PoolTeilToBK.Barcode) >= 30) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,30,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,30,1) AS int) * 1, 0) +
  IIF((LEN(#PoolTeilToBK.Barcode) >= 31) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,31,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,31,1) AS int) * 3, 0) +
  IIF((LEN(#PoolTeilToBK.Barcode) >= 32) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,32,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,32,1) AS int) * 1, 0) +
  IIF((LEN(#PoolTeilToBK.Barcode) >= 33) AND (TRY_CAST(SUBSTRING(#PoolTeilToBK.Barcode,33,1) AS int) IS NOT NULL), CAST(SUBSTRING(#PoolTeilToBK.Barcode,33,1) AS int) * 3, 0)
FROM #PoolTeilToBK;
 
UPDATE #BKTeileBarcodeVergabe SET Barcode = RTRIM(Barcode) + '0'                               WHERE BarcodeNum % 10 = 0;
UPDATE #BKTeileBarcodeVergabe SET Barcode = RTRIM(Barcode) + CHAR(48 + 10 - (BarcodeNum % 10)) WHERE BarcodeNum % 10 > 0;
 
UPDATE #PoolTeilToBK SET NeuBarcode = #BKTeileBarcodeVergabe.Barcode
FROM #BKTeileBarcodeVergabe
WHERE #BKTeileBarcodeVergabe.EinzHistID = #PoolTeilToBK.EinzHistID;
 
SELECT EinzHist.ID
INTO #ExistierBereits
FROM #PoolTeilToBK, EinzHist
WHERE #PoolTeilToBK.Barcode = Einzhist.RentomatChip
  AND EinzHist.Archiv = 0
  AND Einzhist.EinzHistTyp = 1;
 
DELETE FROM #PoolTeilToBK
WHERE EinzHistID IN (SELECT ID FROM #ExistierBereits);
 
DELETE FROM #PoolTeilToBK
WHERE EXISTS (SELECT * FROM Einzteil WHERE #PoolTeilToBK.Barcode = Einzteil.Code2);

/* UPDATE auf Live-Tabellen mit Transaction-Absicherung, falls bei einem der beiden Updates ein Fehler auftritt! */
BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE EinzHist SET EinzHist.Barcode = #PoolTeilToBK.NeuBarcode, EinzHist.Rentomatchip = #PoolTeilToBK.Barcode
    FROM #PoolTeilToBK
    WHERE #PoolTeilToBK.EinzHistID = EinzHist.ID;
    
    UPDATE EinzTeil SET Code = #PoolTeilToBK.NeuBarcode, Code2 = #PoolTeilToBK.Barcode
    FROM #PoolTeilToBK
    WHERE #PoolTeilToBK.EinzTeilID = EinzTeil.ID;
  
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