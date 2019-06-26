WITH Speicherscan AS (
  SELECT Scans.ID, Scans.TeileID, Scans.DateTime, Scans.ZielNrID, NextScanID = (
    SELECT MIN(NextScan.ID)
    FROM Scans AS NextScan
    WHERE NextScan.TeileID = Scans.TeileID
      AND NextScan.DateTime > Scans.DateTime
  )
  FROM Scans
  WHERE Scans.ZielNrID = (SELECT ID FROM ZielNr WHERE ZielNrBez = N'Lenzing1: > Speicher')
),
Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'Teile')
)
SELECT Teile.Barcode, Teilestatus.StatusBez AS Teilestatus, Speicherscan.DateTime AS [Zeitpunkt Speicher-Scan], Scans.[DateTime] AS [Folge-Scan-Zeitpunkt], ZielNr.ZielNrBez AS [Folge-Scan-Ort], Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Traeger.Traeger, Traeger.Vorname, Traeger.Nachname, Vsa.VsaNr, Vsa.SuchCode AS [VSA-Stichwort], Kunden.KdNr, Kunden.SuchCode AS Kunde
FROM Teile
JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Speicherscan ON Speicherscan.TeileID = Teile.ID
JOIN Scans ON Speicherscan.NextScanID = Scans.ID
JOIN ZielNr ON Scans.ZielNrID = ZielNr.ID
JOIN Teilestatus ON Teile.[Status] = Teilestatus.[Status]
WHERE Vsa.StandKonID = (SELECT ID FROM StandKon WHERE StandKonBez = N'BK: Lenzing1')
  AND Teile.Eingang1 > N'2019-05-14'
  AND DATEDIFF(day, Speicherscan.[DateTime], Scans.[DateTime]) > 7;