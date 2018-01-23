TRY
  DROP TABLE #TmpLsPo;
  DROP TABLE #TmpLsPoBer;
  DROP TABLE #TmpUpdLsPo;
CATCH ALL END;

SELECT LsPo.ID AS LsPoID, LsPo.LsKoID, LsKo.VsaID, LsPo.KdArtiID, LsKo.ProduktionID AS LsKoProdID, LsPo.ProduktionID AS LsPoProdID, LsKo.User_
INTO #TmpLsPo
FROM LsPo, LsKo
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKo.Datum >= '01.02.2012';
  
SELECT LsPo.LsPoID, LsPo.LsKoID, LsPo.VsaID, LsPo.KdArtiID, LsPo.LsKoProdID, LsPo.LsPoProdID, Artikel.ArtikelNr, Artikel.SuchCode, Bereich.ID AS BereichID, Bereich.Bereich, Vsa.StandKonID, LsPo.User_
INTO #TmpLsPoBer
FROM #TmpLsPo LsPo, KdArti, Artikel, Bereich, Vsa
WHERE LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Artikel.BereichID = Bereich.ID
  AND LsPo.VsaID = Vsa.ID
  AND Bereich.Bereich IN ('TW', 'EWT');
  
SELECT LsPoBer.LsPoID, LsPoBer.LsKoID, LsPoBer.VsaID, LsPoBer.KdArtiID, LsPoBer.LsKoProdID, LsPoBer.LsPoProdID, StandBer.ProduktionID AS StandBerProdID, Standort.Bez AS Standort, LsPoBer.StandKonID, LsPoBer.ArtikelNr, LsPoBer.SuchCode, LsPoBer.Bereich, LsPoBer.User_
INTO #TmpUpdLsPo
FROM #TmpLsPoBer LsPoBer, StandBer, Standort
WHERE LsPoBer.StandKonID = StandBer.StandKonID
  AND LsPoBer.BereichID = StandBer.BereichID
  AND StandBer.ProduktionID = Standort.ID
  AND LsPoBer.LsPoProdID <> StandBer.ProduktionID;
  
UPDATE LsPo SET LsPo.ProduktionID = UpdLsPo.StandBerProdID
FROM LsPo, #TmpUpdLsPo UpdLsPo
WHERE UpdLsPo.LsPoID = LsPo.ID;