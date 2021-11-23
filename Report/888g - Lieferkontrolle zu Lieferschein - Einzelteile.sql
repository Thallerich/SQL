IF object_id('tempdb..#TmpFinal') IS NOT NULL
BEGIN
  DROP TABLE #TmpFinal;
END

SELECT LsKo.LsNr, LsKo.Datum AS Lieferdatum, OPTeile.Code, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, OPScans.Zeitpunkt AS Ausgangsscan, CONVERT(datetime, NULL) AS PortalScan, CONVERT(datetime, NULL) AS SortierstandScan, OPTeile.ID AS OPTeileID, CONVERT(datetime, NULL) AS NaechsterEingang, CONVERT(integer, NULL) AS ZielNrID
INTO #TmpFinal
FROM OPScans, OPTeile, Artikel, AnfPo, AnfKo, LsKo, ArtGroe
WHERE OPScans.OPTeileID = OPTeile.ID
  AND OPTeile.ArtikelID = Artikel.ID
  AND OPTeile.ArtGroeID = ArtGroe.ID
  AND OPScans.AnfPoID = AnfPo.ID
  AND AnfPo.AnfKoID = AnfKo.ID
  AND AnfKo.LsKoID = LsKo.ID
  AND LsKo.LsNr = $1$;

UPDATE Final SET Final.PortalScan = x.PortalScan
FROM #TmpFinal AS Final, (
  SELECT MAX(y.Zeitpunkt) AS PortalScan, y.OPTeileID
  FROM (
    SELECT OPScans.*
    FROM OPScans, #TmpFinal AS Final
    WHERE OPScans.OPTeileID = Final.OPTeileID
      AND OPScans.ZielNrID = 278
      AND OPScans.Zeitpunkt > Final.Lieferdatum
  ) AS y
  GROUP BY y.OPTeileID
) AS x
WHERE x.OPTeileID = Final.OPTeileID;

UPDATE Final SET Final.SortierstandScan = x.SortierstandScan
FROM #TmpFinal AS Final, (
  SELECT MAX(y.Zeitpunkt) AS SortierstandScan, y.OPTeileID
  FROM (
    SELECT OPScans.*
    FROM OPScans, #TmpFinal AS Final
    WHERE OPScans.OPTeileID = Final.OPTeileID
      AND OPScans.ZielNrID IN (272, 273)
      AND OPScans.Zeitpunkt > Final.Lieferdatum
  ) AS y
  GROUP BY y.OPTeileID
) AS x
WHERE x.OPTeileID = Final.OPTeileID;

IF object_id('tempdb..#TmpOPScans') IS NOT NULL
BEGIN
  DROP TABLE #TmpOPScans;
END

SELECT OPScans.*
INTO #TmpOPScans
FROM OPScans, #TmpFinal AS Final
WHERE OPScans.OPTeileID = Final.OPTeileID
  AND OPScans.Zeitpunkt > Final.Lieferdatum
  AND OPScans.ZielNrID IN (SELECT ID FROM ZielNr WHERE GeraeteNr IS NOT NULL AND ZielGrpID = 1);

UPDATE Final SET Final.NaechsterEingang = x.Zeitpunkt, Final.ZielNrID = x.ZielNrID
FROM #TmpFinal AS Final, (
  SELECT OPScans.Zeitpunkt, OPScans.ZielNrID, OPScans.OPTeileID
  FROM #TmpOPScans AS OPScans, (
    SELECT MIN(OPMinScan.ID) AS OPScansID, OPMinScan.OPTeileID
    FROM #TmpOPScans AS OPMinScan
    GROUP BY OPMinScan.OPTeileID
  ) AS y
  WHERE OPScans.ID = y.OPScansID
) AS x
WHERE x.OPTeileID = Final.OPTeileID;

SELECT LsNr, Lieferdatum, Code, ArtikelNr, Artikelbezeichnung, Größe, Ausgangsscan, PortalScan AS "PortalScan [Rankweil]", SortierstandScan AS "SortierstandScan [Rankweil]", NaechsterEingang, ZielNr.ZielNrBez$LAN$ AS Eingangsort
FROM #TmpFinal AS Final
LEFT OUTER JOIN ZielNr ON ZielNr.ID = Final.ZielNrID;