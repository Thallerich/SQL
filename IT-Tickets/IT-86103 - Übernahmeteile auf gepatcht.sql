DECLARE @EinzHistPatch TABLE (
  EinzHistID int PRIMARY KEY CLUSTERED
);

INSERT INTO @EinzHistPatch (EinzHistID)
SELECT EinzHist.ID
FROM EinzHist WITH (UPDLOCK)
JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
WHERE EinzHist.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = 10006714)
  AND EinzHist.[Status] = N'K'
  AND EinzHist.ID = (SELECT EinzTeil.CurrEinzHistID FROM EinzTeil WHERE EinzTeil.ID = EinzHist.EinzTeilID)
  AND KdArti.EigentumID IN (SELECT Eigentum.ID FROM Eigentum WHERE Eigentum.ScanInUebern = 1);

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE EinzHist SET [Status] = N'M', PatchDatum = CAST(GETDATE() AS date)
    WHERE ID IN (SELECT EinzHistID FROM @EinzHistPatch);
  
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