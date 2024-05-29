DECLARE @artikel nvarchar(20) = N'SX5563';

DECLARE @SetToDelete TABLE (
  OPEtiKoID int,
  OPEtiPoID int
);

INSERT INTO @SetToDelete (OPEtiKoID, OPEtiPoID)
SELECT OPEtiPo.OPEtiKoID, OPEtiPo.ID AS OPEtiPoOD
FROM OPEtiPo
JOIN OPEtiKo ON OPEtiPo.OPEtiKoID = OPEtiKo.ID
WHERE OPEtiKo.ArtikelID = (SELECT ID FROM Artikel WHERE ArtikelNr = @artikel);

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE Scans SET OPEtiKoID = -1
    WHERE OPEtiKoID IN (SELECT OPEtiKoID FROM @SetToDelete);

    UPDATE EinzTeil SET LastOpEtiKoID = -1
    WHERE LastOpEtiKoID IN (SELECT OPEtiKoID FROM @SetToDelete);

    DELETE FROM OPEtiPo
    WHERE ID IN (SELECT OPEtiPoID FROM @SetToDelete);

    DELETE FROM OPEtiKo
    WHERE ID IN (SELECT OPEtiKoID FROM @SetToDelete);
  
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