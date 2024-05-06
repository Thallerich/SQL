DECLARE @VsaAnfSoCleanup TABLE (
  VsaAnfSoID int
);

INSERT INTO @VsaAnfSoCleanup (VsaAnfSoID)
SELECT VsaAnfSo.ID
FROM VsaAnfSo
JOIN VsaAnf ON VsaAnfSo.VsaAnfID = VsaAnf.ID
JOIN AnfPo ON VsaAnfSo.AnfPoID = AnfPo.ID
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
WHERE VsaAnfSo.AusstehendeReduz != 0
  AND VsaAnfSo.Art != N'V'
  AND NOT EXISTS (
    SELECT LsPo.*
    FROM LsPo
    WHERE LsPo.LsKoID = AnfKo.LsKoID
      AND LsPo.KdArtiID = VsaAnf.KdArtiID
  );

BEGIN TRY
  BEGIN TRANSACTION;
  
    DELETE FROM VsaAnfSo
    WHERE ID IN (
      SELECT VsaAnfSoID
      FROM @VsaAnfSoCleanup
    );
  
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