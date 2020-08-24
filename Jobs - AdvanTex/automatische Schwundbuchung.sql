DECLARE @KdNr AS TABLE (KdNr int);

INSERT INTO @KdNr VALUES (24045), (11050), (20000), (6071), (7240), (9013), (23041), (23042), (23032), (23037), (10001756), (242013), (2710499), (2710498), (18029), (245347), (248564), (246805);

DROP TABLE IF EXISTS #TmpSchwundAuto;
DROP TABLE IF EXISTS #TmpVsaAnf;

SELECT OPTeile.ID AS OPTeileID, IIF(OPTeile.LastErsatzFuerKdArtiID < 0, OPTeile.ArtikelID, KdArti.ArtikelID) AS ArtikelID, OPTeile.VsaID AS VsaID
INTO #TmpSchwundAuto
FROM OPTeile, Vsa, Kunden, KdArti
WHERE OPTeile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND OPTeile.LastErsatzFuerKdArtiID = KdArti.ID
  AND Kunden.KdNr IN (SELECT KdNr FROM @KdNr)
  AND OPTeile.Status = 'Q'
  AND OPTeile.LastActionsID = 102
  AND DATEDIFF(day, OPTeile.LastScanTime, GETDATE()) > 180;

UPDATE OPTeile SET Status = 'W', LastActionsID = 116
WHERE ID IN (
  SELECT OPTeileID FROM #TmpSchwundAuto
);

/*
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
  AND Kunden.KdNr IN (SELECT KdNr FROM @KdNr);

UPDATE VsaAnf SET VsaAnf.BestandIst = VA.BestandIst
FROM VsaAnf, #TmpVsaAnf AS VA
WHERE VsaAnf.ID = VA.ID;
*/

DROP TABLE IF EXISTS #TmpSchwundAuto;
DROP TABLE IF EXISTS #TmpVsaAnf;