--SELECT VsaAnf.ID AS VsaAnfID, VsaAnf.Status, VsaAnf.KdArtiID, VsaAnf.ArtGroeID, ArtGroe.ID AS ArtGroeIDArtikel
UPDATE VsaAnf SET ArtGroeID = ArtGroe.ID
FROM VsaAnf
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN ArtGroe ON ArtGroe.ArtikelID = Artikel.ID
WHERE Artikel.ArtikelNr IN (N'54A7L', N'54A7XL')
  AND Bereich.VsaAnfGroe = 1
  AND VsaAnf.ArtGroeID != ArtGroe.ID;

GO

DECLARE @AnfKorr TABLE (
  AnfPoIDOld int,
  AnfPoIDNew int,
  ArtGroeID int,
  AngefordertOld float
);

INSERT INTO @AnfKorr (AnfPoIDOld, AnfPoIDNew, ArtGroeID, AngefordertOld)
SELECT AnfPo.ID AS AnfPoID, AnfPoGroe.ID, AnfPoGroe.ArtGroeID, AnfPo.Angefordert
FROM AnfPo
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN ArtGroe ON ArtGroe.ArtikelID = Artikel.ID
JOIN AnfPo AS AnfPoGroe ON AnfPoGroe.AnfKoID = AnfPo.AnfKoID AND AnfPoGroe.KdArtiID = AnfPo.KdArtiID AND AnfPoGroe.ArtGroeID > 0
WHERE Artikel.ArtikelNr IN (N'54A7L', N'54A7XL')
  AND Bereich.VsaAnfGroe = 1
  AND AnfKo.Status < N'I'
  AND AnfPo.ArtGroeID != ArtGroe.ID;

UPDATE AnfPo SET Angefordert = Angefordert + AnfKorr.AngefordertOld
FROM AnfPo
JOIN @AnfKorr AS AnfKorr ON AnfKorr.AnfPoIDNew = AnfPo.ID;

UPDATE OPScans SET EingAnfPoID = AnfKorr.AnfPoIDNew
FROM OPScans
JOIN @AnfKorr AS AnfKorr ON OPScans.EingAnfPoID = AnfKorr.AnfPoIDOld;

DELETE FROM AnfPo
WHERE AnfPo.ID IN (
  SELECT AnfPoIDOld
  FROM @AnfKorr
);

GO