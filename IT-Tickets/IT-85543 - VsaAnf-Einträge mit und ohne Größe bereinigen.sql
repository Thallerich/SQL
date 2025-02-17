DROP TABLE IF EXISTS #VsaAnf;
DROP TABLE IF EXISTS #AnfPo;
GO

SELECT VsaAnf.ID, VsaAnf.VsaID, VsaAnf.KdArtiID, VsaAnf.ArtGroeID, Bereich.Bereich, Bereich.VsaAnfGroe
INTO #VsaAnf
FROM VsaAnf
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID AND KdArti.Status = 'A'
JOIN KdBer ON KdArti.KdBerID = KdBer.ID AND KdBer.Status = 'A'
JOIN Bereich ON KdBer.BereichID = Bereich.ID AND Bereich.VsaAnfGroe = 0
JOIN Kunden ON KdArti.KundenID = Kunden.ID AND Kunden.Status = 'A'
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID AND Vsa.Status = 'A'
WHERE VsaAnf.ArtGroeID > -1
AND VsaAnf.Status < 'I';

SELECT AnfPo.ID, AnfPo.KdArtiID, AnfPo.ArtGroeID
INTO #AnfPo
FROM AnfPo
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN #VsaAnf ON AnfPo.KdArtiID = #VsaAnf.KdArtiID AND AnfPo.ArtGroeID = #VsaAnf.ArtGroeID
WHERE AnfKo.Lieferdatum >= CAST(GETDATE() AS date)
  AND AnfKo.LsKoID < 0;

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

    UPDATE AnfPo SET ArtGroeID = -1
    WHERE ID IN (
        SELECT #AnfPo.ID
        FROM #AnfPo
      )
      AND NOT EXISTS (
        SELECT a.*
        FROM AnfPo AS a
        WHERE a.KdArtiID = AnfPo.KdArtiID
          AND a.AnfKoID = AnfPo.AnfKoID
          AND a.ArtGroeID = -1
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