CREATE TABLE #AnfOffenCleanup (
  AnfOffenID int PRIMARY KEY CLUSTERED
);

BEGIN TRY
  BEGIN TRANSACTION;
  
    /* Alte Einträge löschen */
    INSERT INTO #AnfOffenCleanup (AnfOffenID)
    SELECT AnfOffen.ID
    FROM AnfOffen WITH (UPDLOCK)
    WHERE AnfOffen.BezugsDatum < DATEADD(day, -90, GETDATE());

    /* Einträge inaktiver VSA's löschen */
    INSERT INTO #AnfOffenCleanup (AnfOffenID)
    SELECT AnfOffen.ID
    FROM AnfOffen WITH (UPDLOCK)
    JOIN Vsa ON AnfOffen.VsaID = Vsa.ID
    WHERE Vsa.Status != N'A'
      AND NOT EXISTS (SELECT * FROM #AnfOffenCleanup WHERE #AnfOffenCleanup.AnfOffenID = AnfOffen.ID);

    /* Einträge aus Tabelle löschen */
    DELETE FROM AnfOffen
    WHERE ID IN (SELECT AnfOffenID FROM #AnfOffenCleanup);
  
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

DROP TABLE #AnfOffenCleanup;