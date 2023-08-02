DROP TABLE IF EXISTS #Vsa;
GO

CREATE TABLE #Vsa (
  VsaID int PRIMARY KEY CLUSTERED
);

GO

INSERT INTO #Vsa (VsaID)
SELECT DISTINCT Vsa.ID
FROM Vsa
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID
JOIN Standort ON StandBer.ProduktionID = Standort.ID
WHERE Standort.SuchCode = N'SAWR'
  AND Vsa.CodeType1ID = -1
  AND EXISTS (
    SELECT EinzHist.*
    FROM EinzHist
    JOIN EinzTeil ON EinzHist.EinzTeilID = EinzTeil.ID
    JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
    JOIN KdBer ON KdArti.KdBerID = KdBer.ID
    WHERE EinzHist.VsaID = Vsa.ID
      AND KdBer.BereichID = StandBer.BereichID
      AND EinzHist.EinzHistTyp = 1
      AND EinzHist.PoolFkt = 0
      AND EinzHist.IsCurrEinzHist = 1
      AND EinzTeil.AltenheimModus = 0
      AND EinzHist.[Status] BETWEEN N'A' AND N'Q'
  )
  AND NOT EXISTS (
    SELECT EinzHist.*
    FROM EinzHist
    JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
    JOIN KdBer ON KdArti.KdBerID = KdBer.ID
    WHERE EinzHist.VsaID = Vsa.ID
      AND (KdBer.BereichID = (SELECT ID FROM Bereich WHERE Bereich = N'CR') OR LEN(EinzHist.Barcode) = 24)
      AND EinzHist.EinzHistTyp = 1
      AND EinzHist.PoolFkt = 0
      AND EinzHist.IsCurrEinzHist = 1
      AND EinzHist.[Status] = N'Q'
  );

GO

RAISERROR(N'Pre-Select done', 0, 1) WITH NOWAIT;

IF OBJECT_ID('_VsaCodeType') IS NULL
  CREATE TABLE _VsaCodeType (
    VsaID int PRIMARY KEY CLUSTERED,
    CodeType1ID int,
    ChangedStamp datetime2 DEFAULT GETDATE()
  );

GO

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE Vsa SET CodeType1ID = (SELECT ID FROM CodeType WHERE CodeTypeBez = N'UHF')
    OUTPUT deleted.ID, deleted.CodeType1ID
    INTO _VsaCodeType (VsaID, CodeType1ID)
    WHERE ID IN (SELECT VsaID FROM #Vsa);
  
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