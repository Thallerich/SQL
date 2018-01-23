TRY
  DROP TABLE #TmpOPScans;
  DROP TABLE #TmpAusgangsteile;
  DROP TABLE #TmpTorCheck;
CATCH ALL END;

SELECT OPScans.*
INTO #TmpOPScans
FROM OPScans
WHERE OPScans.Zeitpunkt BETWEEN '26.09.2016 00:00:00' AND '27.09.2016 00:00:00'
  AND OPScans.ZielNrID IN (SELECT ID FROM ZielNr WHERE GeraeteNr IS NOT NULL AND ZielGrpID = 1 AND ProduktionsID = 5005);

SELECT OPScans.OPTeileID, OPScans.Zeitpunkt, OPScans.AnfPoID
INTO #TmpAusgangsteile
FROM (
  SELECT OPScans.*
  FROM OPScans, (
    SELECT MAX(OPScans.ID) AS ID, OPScans.OPTeileID
    FROM OPScans
    WHERE OPScans.Zeitpunkt < '26.09.2016 00:00:00'
      AND OPScans.OPTeileID IN (SELECT DISTINCT OPTeileID FROM #TmpOPScans)
      AND OPScans.AnfPoID > 0
    GROUP BY OPScans.OPTeileID
  ) AS o
  WHERE OPScans.ID = o.ID
) AS OPScans, AnfPo, AnfKo
WHERE OPScans.AnfPoID = AnfPo.ID
  AND AnfPo.AnfKoID = AnfKo.ID
  AND AnfKo.VsaID IN (
    SELECT Vsa.ID
    FROM Vsa, Kunden
    WHERE Vsa.KundenID = Kunden.ID
      AND Kunden.KdNr = 2301
      AND Vsa.SuchCode IN ('130', '090', '080')
    UNION
    SELECT Vsa.ID
    FROM Vsa, Kunden
    WHERE Vsa.KundenID = Kunden.ID
      AND Kunden.KdNr = 23032
      AND Vsa.SuchCode IN ('350')
    UNION
    SELECT Vsa.ID
    FROM Vsa, Kunden
    WHERE Vsa.KundenID = Kunden.ID
      AND Kunden.KdNr = 7240
      AND Vsa.SuchCode IN ('800', '640', '321')
);

SELECT OPTeile.Code, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, MIN(OPScans.Zeitpunkt) AS EingangsscanOhneTor, CONVERT(NULL, SQL_TIMESTAMP) AS ScanzeitTor, OPScans.OPTeileID, 0 AS VsaID
INTO #TmpTorCheck
FROM OPTeile, Artikel, AnfPo, AnfKo, #TmpOPScans AS OPScans
WHERE OPScans.OPTeileID = OPTeile.ID
  AND OPTeile.ArtikelID = Artikel.ID
  AND OPScans.EingAnfPoID = AnfPo.ID
  AND AnfPo.AnfKoID = AnfKo.ID
  AND OPScans.ZielNrID IN (SELECT ID FROM ZielNr WHERE GeraeteNr IS NOT NULL AND ZielGrpID = 1 AND ProduktionsID = 5005 AND ID <> 291)
  AND OPScans.OPTeileID IN (SELECT OPTeileID FROM #TmpAusgangsteile)
GROUP BY OPTeile.Code, Artikel.ArtikelNr, Artikelbezeichnung, OPScans.OPTeileID;

UPDATE TorCheck SET TorCheck.ScanzeitTor = x.Zeitpunkt
FROM #TmpTorCheck AS TorCheck, (
  SELECT OPScans.OPTeileID, MAX(OPScans.Zeitpunkt) AS Zeitpunkt
  FROM #TmpOPScans AS OPScans
  WHERE OPScans.ZielNrID = 291
    AND OPScans.OPTeileID IN (SELECT OPTeileID FROM #TmpTorCheck)
  GROUP BY OPScans.OPTeileID
) AS x
WHERE x.OPTeileID = TorCheck.OPTeileID;

UPDATE TorCheck SET TorCheck.VsaID = AnfKo.VsaID
FROM #TmpTorCheck AS TorCheck, #TmpAusgangsteile AS Ausgangsteile, AnfPo, AnfKo
WHERE TorCheck.OPTeileID = Ausgangsteile.OPTeileID
  AND Ausgangsteile.AnfPoID = AnfPo.ID
  AND AnfPo.AnfKoID = AnfKo.ID;

SELECT Code, ArtikelNr, Artikelbezeichnung, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS Vsa, EingangsscanOhneTor, ScanzeitTor
FROM #TmpTorCheck AS TC, Vsa, Kunden
WHERE TC.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID;