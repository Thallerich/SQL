TRY
  DROP TABLE #TmpFolgeKdArti;
  DROP TABLE #TmpFolgeVsaAnf;
CATCH ALL END;

SELECT KdGf.KurzBez AS SGF, Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, KdArti.ID AS KdArtiID, 0 AS FolgeKdArtiID, KdArti.KundenID
INTO #TmpFolgeKdArti
FROM KdArti, Kunden, Artikel, KdGf
WHERE KdArti.KundenID = Kunden.ID
  AND Kunden.KdGfID = KdGf.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Artikel.ArtikelNr = '111806001101'
  AND Kunden.ID > 0;
  
UPDATE FKdArti SET FKdArti.FolgeKdArtiID = KdArti.ID
FROM #TmpFolgeKdArti AS FKdArti, KdArti, Kunden, Artikel
WHERE KdArti.KundenID = Kunden.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND FKdArti.KundenID = KdArti.KundenID
  AND Artikel.ArtikelNr = '111806001002';

DELETE FROM #TmpFolgeKdArti WHERE FolgeKdArtiID = 0;

UPDATE KdArti SET KdArti.FolgeKdArtiID = FKdArti.FolgeKdArtiID
FROM KdArti, #TmpFolgeKdArti AS FKdArti
WHERE FKdArti.KdArtiID = KdArti.ID;

SELECT VsaAnf.ID AS VsaAnfID, VsaAnf.VsaID, VsaAnf.Bestand, 0 AS FolgeVsaAnfID
INTO #TmpFolgeVsaAnf
FROM VsaAnf, Vsa, #TmpFolgeKdArti AS FKdArti
WHERE VsaAnf.VsaID = Vsa.ID
  AND Vsa.KundenID = FKdArti.KundenID
  AND VsaAnf.KdArtiID = FKdArti.KdArtiID
  AND EXISTS (
    SELECT VsaAnf.*
    FROM VsaAnf
    WHERE VsaAnf.VsaID = Vsa.ID
      AND VsaAnf.KdArtiID = FKdArti.FolgeKdArtiID
  );
  
UPDATE FVsaAnf SET FolgeVsaAnfID = VsaAnf.ID
FROM #TmpFolgeVsaAnf AS FVsaAnf, VsaAnf, Vsa, #TmpFolgeKdArti AS FKdArti
WHERE VsaAnf.KdArtiID = FKdArti.FolgeKdArtiID
  AND VsaAnf.VsaID = Vsa.ID
  AND Vsa.KundenID = FKdArti.KundenID
  AND FVsaAnf.VsaID = Vsa.ID;
  
UPDATE VsaAnf SET VsaAnf.Status = 'E', VsaAnf.Bestand = 0
FROM #TmpFolgeVsaAnf AS FVsaAnf, VsaAnf
WHERE FVsaAnf.VsaAnfID = VsaAnf.ID;

UPDATE VsaAnf SET VsaAnf.Bestand = FVsaAnf.Bestand
FROM #TmpFolgeVsaAnf AS FVsaAnf, VsaAnf
WHERE FVsaAnf.FolgeVsaAnfID = VsaAnf.ID
  AND VsaAnf.Bestand = 0;