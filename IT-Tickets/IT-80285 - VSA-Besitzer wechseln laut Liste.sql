DROP TABLE IF EXISTS #VsaOwnerChange;
GO

CREATE TABLE #VsaOwnerChange (
  EinzTeilID int,
  VsaOwnerID int
);

GO

INSERT INTO #VsaOwnerChange (EinzTeilID, VsaOwnerID)
SELECT EinzTeil.ID,VsaOwner_New.ID
FROM EinzTeil
JOIN _IT80285 ON EinzTeil.Code = _IT80285.Code
JOIN Vsa AS VsaOwner ON EinzTeil.VsaOwnerID = VsaOwner.ID
JOIN Vsa AS VsaOwner_New ON VsaOwner.KundenID = VsaOwner_New.KundenID AND _IT80285.VsaNr_Besitzer = VsaOwner_New.VsaNr;

GO

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE EinzTeil SET VsaOwnerID = #VsaOwnerChange.VsaOwnerID
    FROM #VsaOwnerChange
    WHERE #VsaOwnerChange.EinzTeilID = EinzTeil.ID
      AND #VsaOwnerChange.VsaOwnerID != EinzTeil.VsaOwnerID;
  
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

DROP TABLE IF EXISTS #VsaOwnerChange;
GO