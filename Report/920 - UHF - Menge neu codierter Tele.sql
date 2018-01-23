DECLARE @von date;
DECLARE @bis date;

SET @von = $1$;
SET @bis = DATEADD(day, 1, $2$);

BEGIN TRY
  DROP TABLE #TmpOPScans920;
  DROP TABLE #TmpCoded;
END TRY
BEGIN CATCH
END CATCH;

SELECT OPScans.OPTeileID, OPScans.ZielNrID, OPScans.OPGrundID, CONVERT(date, OPScans.Anlage_) AS EncodeDate
INTO #TmpOPScans920
FROM OPScans
WHERE OPScans.ZielNrID BETWEEN 230 AND 299
  AND OPScans.Zeitpunkt BETWEEN @von AND @bis
  AND OPScans.Menge = 0;
  
SELECT OPScans.EncodeDate, Standort.Bez AS Standort, ZielNr.GeraeteNr AS Reader, ZielNr.ZielNrBez$LAN$ AS Ort, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, COUNT(DISTINCT OPScans.OPTeileID) AS AnzahlCodiert, 0 AS Schrott, Standort.ID AS StandortID, ZielNr.ID AS ZielNrID, Artikel.ID AS ArtikelID
INTO #TmpCoded
FROM #TmpOPScans920 AS OPScans, ZielNr, Standort, OPTeile, Artikel
WHERE OPScans.ZielNrID = ZielNr.ID
  AND ZielNr.ProduktionsID = Standort.ID
  AND OPScans.OPTeileID = OPTeile.ID
  AND OPTeile.ArtikelID = Artikel.ID
  AND Artikel.ID > 0
  AND OPScans.OPGrundID = -1
GROUP BY OPScans.EncodeDate, Standort.Bez, ZielNr.GeraeteNr, ZielNr.ZielNrBez$LAN$, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, Standort.ID, ZielNr.ID, Artikel.ID;

UPDATE Coded SET Schrott = x.AnzSchrott
FROM #TmpCoded AS Coded, (
  SELECT OPScans.EncodeDate, Standort.ID AS StandortID, ZielNr.ID AS ZielNrID, Artikel.ID AS ArtikelID, COUNT(DISTINCT OPScans.OPTeileID) AS AnzSchrott
  FROM #TmpOPScans920 AS OPScans, ZielNr, Standort, OPTeile, Artikel
  WHERE OPScans.ZielNrID = ZielNr.ID
    AND ZielNr.ProduktionsID = Standort.ID
    AND OPScans.OPTeileID = OPTeile.ID
    AND OPTeile.ArtikelID = Artikel.ID
    AND Artikel.ID > 0
    AND OPScans.OPGrundID = 110
  GROUP BY OPScans.EncodeDate, Standort.ID, ZielNr.ID, Artikel.ID
) x
WHERE x.StandortID = Coded.StandortID
  AND x.ZielNrID = Coded.ZielNrID
  AND x.ArtikelID = Coded.ArtikelID
  AND x.EncodeDate = Coded.EncodeDate;
  
SELECT EncodeDate AS CodierDatum, Standort, Reader, ArtikelNr, Artikelbezeichnung, AnzahlCodiert AS [Anzahl codiert], Schrott AS [Anzahl Schrott (neu codieren)]
FROM #TmpCoded;