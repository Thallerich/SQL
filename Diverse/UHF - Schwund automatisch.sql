DECLARE @KdNr integer;

SET @KdNr = 31207;

DROP TABLE IF EXISTS #TmpSchwundAuto;
DROP TABLE IF EXISTS #TmpVsaAnf;

SELECT OPTeile.ID AS OPTeileID, OPTeile.ArtikelID AS ArtikelID, OPTeile.VsaID AS VsaID
INTO #TmpSchwundAuto
FROM OPTeile, Vsa, Kunden
WHERE OPTeile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.KdNr = @KdNr
  AND OPTeile.Status = 'R'
  AND DATEDIFF(day, OPTeile.LastScanTime, GETDATE()) > 180;

UPDATE OPTeile SET Status = 'W'
WHERE ID IN (
  SELECT OPTeileID FROM #TmpSchwundAuto
);

SELECT VsaAnf.ID, VsaAnf.Status, (VsaAnf.Bestand - Schwund.Schwundmenge) - ((VsaAnf.Bestand - Schwund.Schwundmenge) % Artikel.Packmenge) + IIF((VsaAnf.Bestand - Schwund.Schwundmenge) % Artikel.Packmenge = 0, 0, Artikel.Packmenge) AS Bestand, VsaAnf.BestandIst - Schwund.Schwundmenge AS BestandIst
INTO #TmpVsaAnf
FROM VsaAnf, KdArti, Artikel, Vsa, Kunden, (
  SELECT SA.VsaID, SA.ArtikelID, COUNT(SA.OPTeileID) AS Schwundmenge
  FROM #TmpSchwundAuto AS SA
  GROUP BY SA.VsaID, SA.ArtikelID
) AS Schwund
WHERE VsaAnf.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND VsaAnf.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Schwund.VsaID = Vsa.ID
  AND Schwund.ArtikelID = Artikel.ID
  AND Kunden.KdNr = @KdNr;

UPDATE VsaAnf SET VsaAnf.BestandIst = VA.BestandIst
FROM VsaAnf, #TmpVsaAnf AS VA
WHERE VsaAnf.ID = VA.ID;