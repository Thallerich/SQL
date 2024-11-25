DECLARE @ErsatzTeil TABLE (
  EinzTeilID int PRIMARY KEY
);

INSERT INTO @ErsatzTeil (EinzTeilID)
SELECT EinzTeil.ID
FROM EinzTeil
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
JOIN Vsa ON EinzTeil.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.KdNr = 10001805
  AND Artikel.ArtikelNr = N'111220040011'
  AND EinzTeil.Status != N'Z'
  AND EinzTeil.LastActionsID IN (2, 102, 120, 129, 130, 136, 137, 154, 173);

BEGIN TRY
  
  BEGIN TRANSACTION;

    UPDATE EinzTeil SET LastErsatzFuerKdArtiID = -1, LastErsatzArtGroeID = -1
    WHERE ID IN (SELECT EinzTeilID FROM @ErsatzTeil)
      AND (LastErsatzFuerKdArtiID != 0 OR LastErsatzArtGroeID != 0);

  COMMIT TRANSACTION;

END TRY
BEGIN CATCH
  DECLARE @Message varchar(MAX) = ERROR_MESSAGE();
  DECLARE @Severity int = ERROR_SEVERITY();
  DECLARE @State smallint = ERROR_STATE();

  IF XACT_STATE() != 0
    ROLLBACK TRANSACTION;
 
  RAISERROR(@Message, @Severity, @State);
END CATCH;