DECLARE @KdNr AS TABLE (KdNr int);

INSERT INTO @KdNr VALUES (24045), (11050), (20000), (6071), (7240), (9013), (23041), (23042), (23032), (23037), (10001756), (242013), (2710499), (2710498), (18029), (245347), (248564), (246805), (10003247), (19080), (20156), (25033);

DROP TABLE IF EXISTS #TmpSchwundAuto;

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

DROP TABLE IF EXISTS #TmpSchwundAuto;