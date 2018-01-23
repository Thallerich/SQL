TRY
  DROP TABLE #TmpSetimSet;
  DROP TABLE #TmpSetReturned;
CATCH ALL END;

SELECT OPEtiKo.ID AS OPEtiKoID, OPEtiKo.Status, OPEtiKo.EtiNr, OPTeile.ID AS OPTeileID, OPTeile.Code, OPTeile.Status, OPTeile.ArtikelID
INTO #TmpSetimSet
FROM OPEtiPo, OPEtiKo, OPTeile
WHERE OPEtiPo.OPEtiKoID = OPEtiKo.ID
  AND OPEtiPo.OPTeileID = OPTeile.ID
  AND OPEtiPo.OPTeileID > 0
  AND OPTeile.ArtikelID IN (
    SELECT OPSets.ArtikelID
    FROM OPSets
    WHERE OPSets.ArtikelID > 0
  )
  AND OPEtiKo.Status = 'R';
  
SELECT SiS.OPEtiKoID, SiS.OPTeileID
INTO #TmpSetReturned
FROM OPEtiKo, #TmpSetimSet SiS
WHERE OPEtiKo.EtiNr = SiS.Code
  AND OPEtiKo.Status IN ('U', 'X');
  
UPDATE OPTeile SET Status = 'C' WHERE ID IN (SELECT OPTeileID FROM #TmpSetReturned);
UPDATE OPEtiKo SET Status = 'U' WHERE ID IN (SELECT OPEtiKoID FROM #TmpSetReturned);