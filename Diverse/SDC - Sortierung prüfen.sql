WITH TCPLog AS (
  SELECT SdcTcpL.*
  FROM SdcTcpL
  WHERE SdcTcpL.TransNr = 611
    AND SdcTcpL.Stamp BETWEEN N'2019-07-12 12:00:00' AND N'2019-07-12 23:59:59'
)
SELECT Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS [VSA-Stichwort], Vsa.Bez AS [VSA-Bezeichnung], Traeger.Nachname, Traeger.Vorname, Schrank.SchrankNr, TraeFach.Fach, Teile.Barcode, SUBSTRING(TCPLog.[Message], 88, 10) AS Tour, SUBSTRING(TCPLog.[Message], 98, 10) AS Folge, SUBSTRING(TCPLog.Message, 108, 10) AS [Kunde/VSA], SUBSTRING(TCPLog.[Message], 138, 60) AS Sortierfolge, MAX(TCPLog.Stamp) AS [Zeitpunkt Aufbügeln]
FROM TcpLog
JOIN Teile ON TcpLog.Barcode = Teile.Barcode
JOIN Traeger ON Teile.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN TraeFach ON TraeFach.TraegerID = Traeger.ID
JOIN Schrank ON TraeFach.SchrankID = Schrank.ID
WHERE Holding.Holding IN (N'VOES', N'VOESAN', N'VOESLE')
  AND Teile.Barcode IN (N'1356281198', N'1376142103', N'2000043902', N'2000044749', N'1385722679')
GROUP BY Holding.Holding, Kunden.KdNr, Kunden.SuchCode, Vsa.SuchCode, Vsa.Bez, Traeger.Nachname, Traeger.Vorname, Schrank.SchrankNr, TraeFach.Fach, Teile.Barcode, SUBSTRING(TCPLog.[Message], 88, 10), SUBSTRING(TCPLog.[Message], 98, 10), SUBSTRING(TCPLog.Message, 108, 10), SUBSTRING(TCPLog.[Message], 138, 60)
ORDER BY Tour, Folge, Sortierfolge;