IF OBJECT_ID('tempdb..#TeileLag_Barcode_Update_WOLE') IS NULL
  CREATE TABLE #TeileLag_Barcode_Update_WOLE (
    EinzHistID int,
    EinzTeilID int
  );
ELSE
  DELETE FROM #TeileLag_Barcode_Update_WOLE;

INSERT INTO #TeileLag_Barcode_Update_WOLE (EinzHistID, EinzTeilID)
SELECT EinzHist.ID, EinzHist.EinzTeilID
FROM BKo, LagerArt, EntnKo, LagerBew, EntnPo, EinzHist
WHERE BKoArtID = 9 /*Umlagerung über Zentrallager*/
  AND BKo.LagerArtID = LagerArt.id
  AND BKo.Status >= N'H'
  AND BKo.Status <> N'Y'
  AND LagerArt.Barcodiert = 0
  AND BKo.IntAuftragID = EntnKo.AuftragID
  AND EntnPo.EntnKoID = EntnKo.ID
  AND LagerBew.EntnPoID = EntnPo.ID
  AND BKo.IntAuftragID > -1
  AND EinzHist.Barcode = LagerBew.Barcode
  AND EinzHist.Status IN (N'XI', N'Y')
  AND BKo.BestNr = 412047017;

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE EinzHist SET Barcode = EinzHist.Barcode + N'*UML', RentomatChip = EinzHist.RentomatChip + N'*UML'
    FROM #TeileLag_Barcode_Update_WOLE u
    WHERE u.EinzHistID = EinzHist.ID;

    UPDATE EinzTeil SET [Code] = EinzTeil.Code + N'*UML', Code2 = EinzTeil.Code2 + N'*UML'
    FROM #TeileLag_Barcode_Update_WOLE u
    WHERE u.EinzTeilID = EinzTeil.ID;

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