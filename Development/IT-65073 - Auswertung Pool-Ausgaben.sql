DECLARE @Barcode nvarchar(33) = N'2068064819';
DECLARE @sqltext nvarchar(max);

SET @sqltext = N'
WITH ScanHistory AS (
  SELECT Scans.ID, Scans.EinzHistID, Scans.[DateTime] AS ScanTime, Scans.ActionsID, Scans.TraegerID, LEAD(Scans.DateTime) OVER (PARTITION BY Scans.EinzHistID ORDER BY Scans.[DateTime], Scans.ID) AS NextScanTime, LEAD(Scans.ActionsID) OVER (PARTITION BY Scans.EinzHistID ORDER BY Scans.[DateTime], Scans.ID) AS NextActionsID
  FROM Scans
  WHERE Scans.ActionsID IN (1, 2)
    AND Scans.ZielNrID IN (1, 2)
    AND Scans.EinzHistID IN (SELECT ID FROM EinzHist WHERE Barcode = @Barcode)
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS Vsa, Traeger.Traeger, Traeger.Vorname, Traeger.Nachname, EinzHist.Barcode, ScanHistory.ScanTime AS [Ausgabezeitpunkt], ScanHistory.NextScanTime AS [Retoure-Zeitpunkt]
FROM ScanHistory
JOIN EinzHist ON ScanHistory.EinzHistID = EinzHist.ID
JOIN Traeger ON ScanHistory.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE EinzHist.Barcode = @Barcode
  AND ScanHistory.ActionsID = 2
ORDER BY Ausgabezeitpunkt DESC;
';

EXEC sp_executesql @sqltext, N'@Barcode nvarchar(33)', @Barcode;

GO