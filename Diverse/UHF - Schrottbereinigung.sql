DECLARE curArtiStar CURSOR AS
SELECT OPTeile.VsaID, OPTeile.ArtikelID, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, OPTeile.Status, COUNT(OPTeile.Code) AS AnzStar
FROM OPTeile, Vsa, Kunden, Artikel
WHERE OPTeile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND OPTeile.Code LIKE '%*'
  AND OPTeile.RechPoID < 0
  AND OPTeile.Status = 'R'
  AND OPTeile.ArtikelID = Artikel.ID
  AND Artikel.EAN IS NOT NULL
GROUP BY OPTeile.VsaID, OPTeile.ArtikelID, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, OPTeile.Status;

OPEN curArtiStar;

WHILE FETCH curArtiStar DO
  UPDATE OPTeile SET OPTeile.Status = 'Z', OPTeile.WegGrundID = 110, OPTeile.WegDatum = CURDATE()
  WHERE ID IN (
    SELECT TOP 10 OPTeile.ID
    FROM OPTeile
    WHERE OPTeile.VsaID = curArtiStar.VsaID
      AND OPTeile.ArtikelID = curArtiStar.ArtikelID
      AND OPTeile.Code LIKE '%*'
      AND OPTeile.Status = 'R'
      AND OPTeile.RechPoID < 0
  );
END WHILE;

CLOSE curArtiStar;

-- Korrektur Ist-Bestände
TRY
  DROP TABLE #TmpUpd;
CATCH ALL END;

SELECT CURDATE() AS Datum, VsaAnf.ID AS VsaAnfID, Kunden.KdNr, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez, VsaAnf.Bestand, VsaAnf.BestandIst, (SELECT COUNT(OPTeile.ID) FROM OPTeile WHERE OPTeile.VsaID = Vsa.ID AND OPTeile.ArtikelID = Artikel.ID AND OPTeile.Status = 'R' AND OPTeile.VsaID > 0) AS TeileKd
INTO #TmpUpd
FROM Vsa, KdArti, KdBer, VsaAnf, Kunden, Artikel
WHERE Vsa.KundenID = KdBer.KundenID
  AND Kunden.ID = Vsa.KundenID
  AND KdArti.KdBerID = KdBer.ID
  AND Artikel.ID = KdArti.ArtikelID
  AND KdBer.IstBestandAnpass = TRUE
  AND VsaAnf.VsaID = Vsa.ID
  AND VsaAnf.KdArtiID = KdArti.ID
  AND Artikel.EAN IS NOT NULL
  AND NOT EXISTS (SELECT * FROM OPSets WHERE ArtikelID = Artikel.ID);

INSERT INTO _BestandKorrLog
SELECT *
FROM #TmpUpd
WHERE BestandIst <> TeileKd;

UPDATE VsaAnf SET BestandIst = Upd.TeileKd
FROM VsaAnf, #TmpUpd Upd
WHERE VsaAnf.ID = Upd.VsaAnfID
  AND Upd.BestandIst <> Upd.TeileKd;

DROP TABLE #TmpUpd;