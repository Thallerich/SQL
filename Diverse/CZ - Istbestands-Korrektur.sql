TRY
  DROP TABLE #TmpAnfBest;
CATCH ALL END;

SELECT VsaAnf.ID AS VsaAnfID, Kunden.KdNr, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez, VsaAnf.Bestand, VsaAnf.BestandIst, COUNT(OPTeile.Code) AS TeileKd
INTO #TmpAnfBest
FROM VsaAnf, Vsa, Kunden, KdArti, ViewArtikel Artikel, OPTeile
WHERE VsaAnf.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND VsaAnf.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Artikel.LanguageID = $LANGUAGE$
  AND OPTeile.VsaID = Vsa.ID
  AND OPTeile.ArtikelID = Artikel.ID
  AND Kunden.FirmaID = 5256 -- Wozabal s.r.o.
  AND OPTeile.Status = 'R'
GROUP BY VsaAnfID, Kunden.KdNr, VsaNr, Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez, VsaAnf.Bestand, VsaAnf.BestandIst
ORDER BY Kunden.KdNr, VsaNr, Artikel.ArtikelNr;

UPDATE VsaAnf SET VsaAnf.BestandIst = AnfBest.TeileKd
FROM VsaAnf, #TmpAnfBest AnfBest
WHERE VsaAnf.ID = AnfBest.VsaAnfID;