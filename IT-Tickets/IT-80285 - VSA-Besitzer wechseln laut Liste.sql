DROP TABLE IF EXISTS #VsaOwnerChange;
GO

CREATE TABLE #VsaOwnerChange (
  EinzTeilID int,
  VsaOwnerID int
);

GO

INSERT INTO #VsaOwnerChange (EinzTeilID, VsaOwnerID)
SELECT EinzTeil.ID, VsaOwnerID = (
  SELECT Vsa.ID
  FROM Vsa
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  WHERE Kunden.KdNr = _IT83096.KdNr
    AND Vsa.VsaNr = _IT83096.VsaBesitzer
)
FROM EinzTeil
JOIN _IT83096 ON EinzTeil.Code = _IT83096.Chipcode COLLATE Latin1_General_CS_AS;

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