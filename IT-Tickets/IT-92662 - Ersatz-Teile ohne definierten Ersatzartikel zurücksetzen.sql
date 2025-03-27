DROP TABLE IF EXISTS #EinzTeilFix;
GO

SELECT EinzTeil.ID
INTO #EinzTeilFix
FROM EinzTeil
JOIN Vsa ON EinzTeil.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.KdNr = 2022
  AND EinzTeil.[Status] != 'Z'
  AND EinzTeil.LastActionsID IN (2, 102, 120, 129, 130, 136, 154, 173)
  AND (EinzTeil.LastErsatzFuerKdArtiID > 0 OR EinzTeil.LastErsatzArtGroeID > 0)
  AND NOT EXISTS (
    SELECT KdArti.*
    FROM KdArti
    WHERE KdArti.KundenID = Kunden.ID
      AND KdArti.ArtikelID = EinzTeil.ArtikelID
      AND KdArti.ErsatzFuerKdArtiID > 0
  );

GO

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE EinzTeil SET LastErsatzFuerKdArtiID = -1, LastErsatzArtGroeID = -1
    WHERE ID IN (SELECT ID FROM #EinzTeilFix);
  
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