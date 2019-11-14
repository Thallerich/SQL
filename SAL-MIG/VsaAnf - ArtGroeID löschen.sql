UPDATE VsaAnf SET ArtGroeID = -1
FROM VsaAnf
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
WHERE VsaAnf.ArtGroeID > 0
  AND Bereich.VsaAnfGroe = 0
  AND NOT EXISTS (
    SELECT v.*
    FROM VsaAnf AS v
    WHERE v.KdArtiID = VsaAnf.KdArtiID
      AND v.VsaID = VsaAnf.VsaID
      AND v.ArtGroeID = -1
  );

SELECT VsaAnf.*
FROM VsaAnf
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
WHERE VsaAnf.ArtGroeID > 0
  AND Bereich.VsaAnfGroe = 0
  AND EXISTS (
    SELECT v.*
    FROM VsaAnf AS v
    WHERE v.KdArtiID = VsaAnf.KdArtiID
      AND v.VsaID = VsaAnf.VsaID
      AND v.ArtGroeID = -1
  );