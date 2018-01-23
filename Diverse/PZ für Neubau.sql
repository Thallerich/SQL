TRY
  DROP TABLE #TmpAnf;
CATCH ALL END;

SELECT AnfKo.ID AS AnfKoID, AnfKo.Status, AnfKo.AuftragsNr
INTO #TmpAnf
FROM AnfKo, Vsa
WHERE AnfKo.VsaID = Vsa.ID
  AND Vsa.StandKonID IN (205, 58)
  AND AnfKo.Lieferdatum >= CURDATE()
  AND AnfKo.Status <= 'I'
  AND (AnfKo.PZArtID <> 1 OR AnfKo.ProduktionID <> 5005)
  AND EXISTS (
    SELECT AnfPo.*
    FROM AnfPo, KdArti, Artikel
    WHERE AnfPo.KdArtiID = KdArti.ID
      AND KdArti.ArtikelID = Artikel.ID
      AND Artikel.EAN IS NOT NULL
      AND AnfPo.AnfKoID = AnfKo.ID
      AND AnfPo.Angefordert > 0
  );
  
UPDATE AnfKo SET ProduktionID = 5005, PzArtID = 1 WHERE AnfKo.ID IN (SELECT AnfKoID FROM #TmpAnf);
  
INSERT INTO AnfExpQ
SELECT GetNextID('ANFEXPQ') AS ID, 'U' AS Typ, AnfKo.AnfKoID, 1 AS BearbSys, AnfKo.AuftragsNr, NOW() AS Anlage_, NOW() AS Update_, 'STHA' AS User_, 'STHA' AS AnlageUser_
FROM #TmpAnf AnfKo
WHERE AnfKo.Status = 'I';