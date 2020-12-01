DECLARE @von datetime2;
DECLARE @bis datetime2;

SET @von = CONVERT(datetime2, CONVERT(char(10), GETDATE(), 120) + ' 00:00:00');
SET @bis = CONVERT(datetime2, CONVERT(char(10), GETDATE(), 120) + ' 23:59:59');

SELECT ZielNr.ID AS ZielNr, Standort.Bez AS Standort, ZielNr.ZielNrBez AS Scanort, FORMAT(OPScans.Zeitpunkt, N'HH') AS Einlesestunde, COUNT(DISTINCT OPScans.OPTeileID) AS [Teile gescannt], COUNT(OPScans.ID) AS [Anzahl Scans]
FROM OPScans, ZielNr, Standort
WHERE OPScans.ZielNrID = ZielNr.ID
  AND ZielNr.ProduktionsID = Standort.ID
  AND OPScans.Zeitpunkt BETWEEN @von AND @bis
  AND ZielNr.ProduktionsID = (SELECT ID FROM Standort WHERE SuchCode = N'SAWR')
GROUP BY ZielNr.ID, Standort.Bez, ZielNr.ZielNrBez, FORMAT(OPScans.Zeitpunkt, N'HH')
ORDER BY ZielNr, Einlesestunde;