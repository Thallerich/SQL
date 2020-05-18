DROP TABLE IF EXISTS #AnfKoStandortUpdate;

SELECT AnfKo.ID
INTO #AnfKoStandortUpdate
FROM AnfKo
WHERE EXISTS (
  SELECT * FROM AnfPo, KdArti, Artikel, Bereich, ArtGru
  WHERE AnfPo.AnfKoID = AnfKo.ID
    AND AnfPo.KdArtiID = KdArti.ID
    AND KdArti.ArtikelID = Artikel.ID
    AND Artikel.BereichID = Bereich.ID
    AND Artikel.ArtGruID = ArtGru.ID
    AND Bereich.IstOP = 1
    AND ArtGru.Steril = 1
    AND AnfPo.Angefordert > 0
  )
  AND AnfKo.ProduktionID IN (SELECT ID FROM Standort WHERE SuchCode LIKE N'WOE%')
  AND AnfKo.ProduktionID != 4
  AND AnfKo.ID > 0
  AND AnfKo.Status BETWEEN 'D' AND 'I'
  AND AnfKo.LieferDatum >= CONVERT(date, GETDATE())

UNION ALL

SELECT AnfKo.ID
FROM AnfKo
WHERE AnfKo.LieferDatum >= CONVERT(date, GETDATE())
AND AnfKo.ID > 0
AND AnfKo.Status BETWEEN 'D' AND 'I'
AND AnfKo.ProduktionID != 4
AND AnfKo.VsaID IN (SELECT Vsa.ID FROM Vsa WHERE Vsa.StandKonID = 58) --OP: Enns
;

UPDATE AnfKo SET ProduktionID = 4
WHERE ID IN (SELECT ID FROM #AnfKoStandortUpdate);