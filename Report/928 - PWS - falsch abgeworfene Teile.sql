WITH ScansCTE AS (
  SELECT Scans.*
  FROM Scans
  WHERE Scans.ActionsID = 47
    AND Scans.[DateTime] BETWEEN $2$ AND DATEADD(day,1, $3$)
)
SELECT Teile.Barcode, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.ID AS VsaID, Vsa.VsaNr, Vsa.Bez AS Vsa, Traeger.ID AS TraegerID, Traeger.Traeger AS BewohnerNr, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ScansCTE.[DateTime] AS [Scan-Zeitpunkt], CAST(LEFT(ScansCTE.Info, 200) AS nvarchar(200)) AS AbwurfInfo
FROM ScansCTE
JOIN Teile ON ScansCTE.TeileID = Teile.ID
JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE Kunden.StandortID IN ($1$);