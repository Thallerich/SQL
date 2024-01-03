DROP TABLE IF EXISTS #EKPreis;
GO

CREATE TABLE #EKPreis (
  ArtikelID int PRIMARY KEY CLUSTERED,
  EKPreis money
);

IF OBJECT_ID(N'__EKPreis_SAFFLA') IS NULL
  CREATE TABLE __EKPreis_SAFFLA (
    ArtikelID int,
    EKPreis money,
    EKPreisWaeID int
  );

GO

BEGIN TRY
  BEGIN TRANSACTION;
  
    WITH EKPreisImport AS (
      SELECT DISTINCT _EKPreis.ArtikelNr, _EKPreis.[EK Preis] AS EKPreis
      FROM _EKPreis
    )
    INSERT INTO #EKPreis
    SELECT Artikel.ID AS ArtikelID, EKPreisImport.EKPreis
    FROM Artikel WITH (UPDLOCK)
    JOIN EKPreisImport ON Artikel.ArtikelNr = EKPreisImport.ArtikelNr
    WHERE Artikel.EkPreis != EKPreisImport.EKPreis;
    
    UPDATE Artikel SET EkPreis = #EKPreis.EKPreis
    OUTPUT deleted.ID, deleted.EkPreis, deleted.EkPreisWaeID
    INTO __EKPreis_SAFFLA (ArtikelID, EKPreis, EKPreisWaeID)
    FROM #EKPreis
    WHERE #EKPreis.ArtikelID = Artikel.ID;
  
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