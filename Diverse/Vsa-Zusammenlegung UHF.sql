USE Wozabal
GO

DROP TABLE IF EXISTS #TmpVsaChange

SELECT x.VsaID, 
  VsaAnf.VsaID AS VsaOldID, 
  VsaAnf.KdArtiID,
  CAST(VsaAnf.Status AS nchar(1)) AS Stat,
  CAST(VsaAnf.Art AS nchar(1)) AS Art,
  ISNULL(x.Bestand, 0) + VsaAnf.Bestand AS BestandNeu, 
  ISNULL(x.BestandIst, 0) + VsaAnf.BestandIst AS BestandIstNeu, 
  ISNULL(x.AusstehendeReduz, 0) + VsaAnf.AusstehendeReduz AS AusstehendeReduz,
  ISNULL(x.Liefern1, 0) + VsaAnf.Liefern1 AS Liefern1,
  ISNULL(x.Liefern2, 0) + VsaAnf.Liefern2 AS Liefern2,
  ISNULL(x.Liefern3, 0) + VsaAnf.Liefern3 AS Liefern3,
  ISNULL(x.Liefern4, 0) + VsaAnf.Liefern4 AS Liefern4,
  ISNULL(x.Liefern5, 0) + VsaAnf.Liefern5 AS Liefern5,
  ISNULL(x.Liefern6, 0) + VsaAnf.Liefern6 AS Liefern6,
  ISNULL(x.Liefern7, 0) + VsaAnf.Liefern7 AS Liefern7,
  ISNULL(x.SollPuffer, 0) + VsaAnf.SollPuffer AS SollPuffer,
  ISNULL(x.IstPuffer, 0) + VsaAnf.IstPuffer AS IstPuffer,
  ISNULL(x.MinPuffer, 0) + VsaAnf.MinPuffer AS MinPuffer,
  VsaAnf.MitInventur,
  VsaAnf.ReduzAb
INTO #TmpVsaChange
FROM VsaAnf
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
LEFT OUTER JOIN (
  SELECT VsaAnf.VsaID, VsaAnf.AbteilID, VsaAnf.Bestand, VsaAnf.BestandIst, VsaAnf.AusstehendeReduz, VsaAnf.KdArtiID, VsaAnf.ArtGroeID, VsaAnf.Liefern1, VsaAnf.Liefern2, VsaAnf.Liefern3, VsaAnf.Liefern4, VsaAnf.Liefern5, VsaAnf.Liefern6, VsaAnf.Liefern7, VsaAnf.SollPuffer, VsaAnf.IstPuffer, VsaAnf.MinPuffer
  FROM VsaAnf
  JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  WHERE Kunden.KdNr = 9013
    AND Vsa.VsaNr = 18
) AS x ON x.KdArtiID = VsaAnf.KdArtiID AND x.ArtGroeID = VsaAnf.ArtGroeID
WHERE Kunden.KdNr = 9013
  AND Vsa.VsaNr = 20

INSERT INTO VsaAnf (Status, VsaID, AbteilID, KdArtiID, Art, Liefern1, Liefern2, Liefern3, Liefern4, Liefern5, Liefern6, Liefern7, SollPuffer, IstPuffer, MinPuffer, MitInventur, Bestand, BestandIst, AusstehendeReduz, ReduzAb) 
SELECT c.Stat AS Status, 2978 AS VsaID, 705289 AS AbteilID, c.KdArtiID, c.Art, c.Liefern1, c.Liefern2, c.Liefern3, c.Liefern4, c.Liefern5, c.Liefern6, c.Liefern7, c.SollPuffer, c.IstPuffer, c.MinPuffer, c.MitInventur, c.BestandNeu, c.BestandIstNeu, c.AusstehendeReduz, c.ReduzAb
FROM #TmpVsaChange AS c
WHERE c.VsaID IS NULL

UPDATE VsaAnf SET Bestand = c.BestandNeu, BestandIst = c.BestandIstNeu, AusstehendeReduz = c.AusstehendeReduz, Liefern1 = c.Liefern1, Liefern2 = c.Liefern2, Liefern3 = c.Liefern3, Liefern4 = c.Liefern4, Liefern5 = c.Liefern5, Liefern6 = c.Liefern6, Liefern7 = c.Liefern7, SollPuffer = c.SollPuffer, IstPuffer = c.IstPuffer, MinPuffer = c.MinPuffer, MitInventur = c.MitInventur, ReduzAb = c.ReduzAb
FROM VsaAnf
JOIN #TmpVsaChange AS c ON c.KdArtiID = VsaAnf.KdArtiID AND c.VsaID = VsaAnf.VsaID
WHERE c.VsaID IS NOT NULL

UPDATE OPTeile SET OPTeile.VsaID = 2978
WHERE ID IN (
  SELECT OPTeile.ID
  FROM OPTeile
  JOIN Vsa ON OPTeile.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  WHERE Kunden.KdNr = 9013
    AND Vsa.VsaNr = 20
)

UPDATE VsaAnf SET Status = N'I'
WHERE VsaAnf.VsaID = 2980

GO