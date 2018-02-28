USE Wozabal;

DROP TABLE IF EXISTS #TmpVsaAnf;

SELECT VsaAnf.*
INTO #TmpVsaAnf
FROM VsaAnf
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
WHERE VsaAnf.BestandIst > 0
--  AND Standort.Bez = N'Budweis';

WAITFOR DELAY '00:02';

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez, VsaAnf_Saved.BestandIst AS [Ist-Bestand alt], VsaAnf.BestandIst AS [Ist-Bestand aktuell], OPScanIn.Anzahl AS [Teile eingelesen]
FROM VsaAnf
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
LEFT OUTER JOIN (
  SELECT OPTeile.VsaID, OPTeile.ArtikelID, COUNT(DISTINCT OPTeile.Code) AS Anzahl
  FROM OPScans
  JOIN OPTeile ON OPScans.OPTeileID = OPTeile.ID
  WHERE OPScans.Zeitpunkt >= DATEADD(minute, -2, GETDATE())
    AND OPScans.EingAnfPoID > 0
  GROUP BY OPTeile.VsaID, OPTeile.ArtikelID
) AS OPScanIn ON OPScanIn.VsaID = Vsa.ID AND OPScanIn.ArtikelID = Artikel.ID
JOIN #TmpVsaAnf AS VsaAnf_Saved ON VsaAnf_Saved.ID = VsaAnf.ID
WHERE VsaAnf.BestandIst > 0
  AND VsaAnf.BestandIst < VsaAnf_Saved.BestandIst
  AND Artikel.EAN IS NOT NULL;