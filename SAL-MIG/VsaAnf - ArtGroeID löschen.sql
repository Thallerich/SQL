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

UPDATE AnfPo SET ArtGroeID = -1
FROM AnfPo
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN VsaAnf ON AnfPo.KdArtiID = VsaAnf.KdArtiID AND AnfKo.VsaID = AnfKo.VsaID
WHERE AnfPo.ArtGroeID > 0
  AND VsaAnf.ArtGroeID < 0
  AND AnfKo.LieferDatum > CAST(GETDATE() AS date)
  AND AnfKo.LsKoID < 0
  AND NOT EXISTS (
    SELECT a.*
    FROM AnfPo AS a
    WHERE a.AnfKoID = AnfKo.ID
      AND a.KdArtiID = AnfPo.KdArtiID
      AND a.ArtGroeID = -1
      AND a.VpsKoID = AnfPo.VpsKoID
      AND a.LsKoGruID = AnfPo.LsKoGruID
      AND a.Kostenlos = AnfPo.Kostenlos
  );

/*
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
  */