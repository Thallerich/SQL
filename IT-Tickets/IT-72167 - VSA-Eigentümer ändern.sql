DROP TABLE IF EXISTS #EinzTeil_NewOwner;

GO

CREATE TABLE #EinzTeil_NewOwner (
  EinzTeilID int PRIMARY KEY CLUSTERED
);

GO

DECLARE @KdNr int = 30777;
DECLARE @VsaNr_Owner int = 1001;

DECLARE @VsaOwnerID int = (
  SELECT Vsa.ID
  FROM Vsa
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  WHERE Kunden.KdNr = @KdNr
    AND Vsa.VsaNr = @VsaNr_Owner
);

BEGIN TRY
  BEGIN TRANSACTION;
  
    INSERT INTO #EinzTeil_NewOwner (EinzTeilID)
    SELECT EinzTeil.ID
    FROM EinzTeil
    JOIN Vsa VsaOwner ON EinzTeil.VsaOwnerID = VsaOwner.ID
    JOIN Kunden KundenOwner ON VsaOwner.KundenID = KundenOwner.ID
    JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
    JOIN Vsa ON EinzTeil.VsaID = Vsa.ID
    JOIN Kunden ON Vsa.KundenID = Kunden.ID
    WHERE (KundenOwner.KdNr = @KdNr OR (EinzTeil.VsaOwnerID = -1 AND Kunden.KdNr = @KdNr))
      AND Artikel.ArtikelBez LIKE N'EW %';

    UPDATE EinzTeil SET VsaOwnerID = @VsaOwnerID
    WHERE ID IN (SELECT EinzTeilID FROM #EinzTeil_NewOwner)
      AND VsaOwnerID != @VsaOwnerID;

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