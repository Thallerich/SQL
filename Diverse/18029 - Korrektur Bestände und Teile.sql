TRY
  DROP TABLE #TmpTeilReal;
  DROP TABLE #TmpTeilDel;
CATCH ALL END;

SELECT OPTeile.ID AS OPTeileID, OPTeile.Status, OPTeile.Code, OPTeile.Code2, OPTeile.LastScanTime, OPTeile.LastOPEtiKoID
INTO #TmpTeilReal
FROM OPTeile
WHERE EXISTS (
  SELECT o.*
  FROM OPTeile o
  WHERE o.Code = OPTeile.Code2
)
  AND OPTeile.ArtikelID = (SELECT ID FROM Artikel WHERE ArtikelNr = '129820000000');

SELECT OPTeile.ID, OPTeile.Status, OPTeile.Code, OPTeile.Code2, OPTeile.LastScanTime, OPTeile.LastOPEtiKoID
INTO #TmpTeilDel
FROM OPTeile
WHERE EXISTS (
  SELECT o.*
  FROM OPTeile o
  WHERE o.Code2 = OPTeile.Code
)
  AND OPTeile.ArtikelID = (SELECT ID FROM Artikel WHERE ArtikelNr = '129820000000');

UPDATE OPEtiKo SET Status = 'U'
WHERE OPEtiKo.ID IN (
  SELECT TeilReal.LastOPEtiKoID
  FROM #TmpTeilReal AS TeilReal, #TmpTeilDel AS TeilDel
  WHERE TeilReal.Code2 = TeilDel.Code
    AND TeilReal.LastScanTime < TeilDel.LastScanTime
    AND TeilReal.Status = 'R'
)
  AND OPEtiKo.Status = 'R';

UPDATE OPTeile SET Status = 'C'
WHERE OPTeile.ID IN (
  SELECT TeilReal.OPTeileID
  FROM #TmpTeilReal AS TeilReal, #TmpTeilDel AS TeilDel
  WHERE TeilReal.Code2 = TeilDel.Code
    AND TeilReal.LastScanTime < TeilDel.LastScanTime
    AND TeilReal.Status = 'R'
);

DELETE FROM OPScans WHERE OPTeileID IN (SELECT ID FROM #TmpTeilDel);

DELETE FROM OPTeile WHERE ID IN (SELECT ID FROM #TmpTeilDel);

UPDATE VsaAnf SET BestandIst = Korr.AnzahlSetsKunde
FROM VsaAnf, (
  SELECT VsaAnf.ID AS VsaAnfID, Artikel.ArtikelBez$LAN$, VsaAnf.BestandIst, x.AnzahlSetsKunde
  FROM VsaAnf, KdArti, Artikel, (
    SELECT OPEtiKo.ArtikelID, COUNT(OPEtiKo.ID) AS AnzahlSetsKunde
    FROM OPEtiKo
    WHERE OPEtiKo.Status = 'R'
      AND OPEtiKo.VsaID = 4240650
    GROUP BY OPEtiKo.ArtikelID
  ) AS x
  WHERE VsaAnf.KdArtiID = KdArti.ID
    AND KdArti.ArtikelID = Artikel.ID
    AND x.ArtikelID = Artikel.ID
    AND VsaAnf.VsaID = 4240650
) AS Korr
WHERE Korr.VsaAnfID = VsaAnf.ID;