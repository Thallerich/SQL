DROP TABLE IF EXISTS #VsaAnf;
GO

SELECT VsaAnf.ID, VsaAnf.VsaID, VsaAnf.KdArtiID, VsaAnf.ArtGroeID, Bereich.Bereich, Bereich.VsaAnfGroe
INTO #VsaAnf
FROM VsaAnf
INNER JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID AND KdArti.Status = 'A'
INNER JOIN KdBer ON KdArti.KdBerID = KdBer.ID AND KdBer.Status = 'A'
INNER JOIN Bereich ON KdBer.BereichID = Bereich.ID AND Bereich.VsaAnfGroe = 0
INNER JOIN Kunden ON KDARTI.KundenID = Kunden.ID AND Kunden.Status = 'A'
INNER JOIN Vsa ON VSAANF.VsaID = Vsa.ID AND Vsa.Status = 'A'
WHERE VsaAnf.ArtGroeID > -1
AND VsaAnf.Status < 'I';

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE VsaAnf SET ArtGroeID = -1
    WHERE ID IN (
      SELECT #VsaAnf.ID
      FROM #VsaAnf
      WHERE NOT EXISTS (
        SELECT VsaAnf.*
        FROM VsaAnf
        WHERE VsaAnf.VsaID = #VsaAnf.VsaID 
          AND VsaAnf.KdArtiID = #VsaAnf.KdArtiID
          AND VsaAnf.ArtGroeID = -1
      )
    );

    DELETE FROM VsaAnf WHERE ID IN (
      SELECT #VsaAnf.ID
      FROM #VsaAnf
      WHERE EXISTS (
        SELECT VsaAnf.*
        FROM VsaAnf
        WHERE VsaAnf.VsaID = #VsaAnf.VsaID 
          AND VsaAnf.KdArtiID = #VsaAnf.KdArtiID
          AND VsaAnf.ArtGroeID = -1
          AND VsaAnf.ID != #VsaAnf.ID
      )
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

GO