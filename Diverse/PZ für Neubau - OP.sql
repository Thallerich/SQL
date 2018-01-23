TRY
  DROP TABLE #TmpAnf;
CATCH ALL END;

SELECT AnfKo.ID
INTO #TmpAnf
FROM AnfKo, Vsa
WHERE EXISTS (
  SELECT * FROM AnfPo, KdArti, Artikel, Bereich, ArtGru
  WHERE AnfPo.AnfKoID = AnfKo.ID
    AND AnfPo.KdArtiID = KdArti.ID
    AND KdArti.ArtikelID = Artikel.ID
    AND Artikel.BereichID = Bereich.ID
    AND Artikel.ArtGruID = ArtGru.ID
    AND Bereich.IstOP = $TRUE$
    AND ArtGru.Steril = $TRUE$
  )
AND EXISTS (
  SELECT *
  FROM AnfPo, KdArti, Artikel
  WHERE AnfPo.AnfKoID = AnfKo.ID
    AND AnfPo.KdArtiID = KdArti.ID
    AND KdArti.ArtikelID = Artikel.ID
    AND Artikel.EAN IS NOT NULL
)
AND AnfKo.ProduktionID = 2
AND AnfKo.ID > 0
AND AnfKo.Status <= 'I'
AND AnfKo.LieferDatum >= CURDATE()
AND AnfKo.VsaID = Vsa.ID
AND Vsa.StandKonID = 205;

UPDATE AnfKo SET ProduktionID = 5005
WHERE ID IN (SELECT ID FROM #TmpAnf);
  
INSERT INTO AnfExpQ
SELECT GetNextID('ANFEXPQ') AS ID, 'U' AS Typ, AnfKo.ID AS AnfKoID, 1 AS BearbSys, AnfKo.AuftragsNr, NOW() AS Anlage_, NOW() AS Update_, 'STHA' AS User_, 'STHA' AS AnlageUser_
FROM AnfKo
WHERE AnfKo.ID IN (SELECT ID FROM #TmpAnf);