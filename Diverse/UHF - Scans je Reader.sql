USE Wozabal;

DECLARE @von datetime;
DECLARE @bis datetime;

SET @von = CONVERT(datetime, CONVERT(char(10), GETDATE(), 120) + ' 00:00:00');
SET @bis = CONVERT(datetime, CONVERT(char(10), GETDATE(), 120) + ' 23:59:59');

SELECT ZielNr.ID AS ZielNr, Standort.Bez AS Standort, ZielNr.ZielNrBez AS Scanort, ZielNr.GeraeteNr, COUNT(DISTINCT OPScans.OPTeileID) AS [Teile gescannt], COUNT(OPScans.ID) AS [Anzahl Scans]
FROM OPScans, ZielNr, Standort
WHERE OPScans.ZielNrID = ZielNr.ID
  AND ZielNr.ProduktionsID = Standort.ID
  AND ZielNr.GeraeteNr IS NOT NULL
  AND OPScans.Zeitpunkt BETWEEN @von AND @bis
GROUP BY ZielNr.ID, Standort.Bez, ZielNr.ZielNrBez, ZielNr.GeraeteNr
ORDER BY ZielNr;