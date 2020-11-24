WITH TCPLog AS (
  SELECT SdcTcpL.*
  FROM SdcTcpL
  WHERE SdcTcpL.TransNr = 611
    AND SdcTcpL.Stamp BETWEEN N'2020-11-19 00:00:00' AND N'2020-11-20 13:30:00'
)
SELECT Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS [VSA-Stichwort], Vsa.Bez AS [VSA-Bezeichnung], Traeger.Traeger, Traeger.Nachname, Traeger.Vorname, Schrank.SchrankNr, TraeFach.Fach, Artikel.ArtikelNr, Teile.Barcode, GroePo.Folge AS Größenfolge, SUBSTRING(TCPLog.[Message], 82, 10) AS Tour, SUBSTRING(TCPLog.[Message], 92, 10) AS Folge, SUBSTRING(TCPLog.Message, 102, 10) AS [Kunde/VSA], SUBSTRING(TCPLog.[Message], 142, 60) AS Sortierfolge, MAX(TCPLog.Stamp) AS [Zeitpunkt Aufbügeln]
FROM TcpLog
JOIN Teile ON TcpLog.Barcode = Teile.Barcode
JOIN Traeger ON Teile.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Artikel ON Teile.ArtikelID = Artikel.ID
JOIN ArtGroe ON Teile.ArtGroeID = ArtGroe.ID
JOIN GroePo ON GroePo.GroeKoID = Artikel.GroeKoID AND GroePo.Groesse = ArtGroe.Groesse
LEFT JOIN TraeFach ON TraeFach.TraegerID = Traeger.ID
LEFT JOIN Schrank ON TraeFach.SchrankID = Schrank.ID
WHERE Teile.Barcode IN (N'8820524409', N'8823165654')
GROUP BY Holding.Holding, Kunden.KdNr, Kunden.SuchCode, Vsa.SuchCode, Vsa.Bez, Traeger.Traeger, Traeger.Nachname, Traeger.Vorname, Schrank.SchrankNr, TraeFach.Fach, Artikel.ArtikelNr, Teile.Barcode, GroePo.Folge, SUBSTRING(TCPLog.[Message], 82, 10), SUBSTRING(TCPLog.[Message], 92, 10), SUBSTRING(TCPLog.Message, 102, 10), SUBSTRING(TCPLog.[Message], 142, 60)
ORDER BY Tour, Folge, Sortierfolge;