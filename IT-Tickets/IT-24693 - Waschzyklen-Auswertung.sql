WITH Scans20180330 AS (
  SELECT Scans.TeileID, COUNT(Scans.ID) AS AnzAuslesen
  FROM Scans
  WHERE Scans.Menge = -1
    AND Scans.DateTime < N'2018-04-01 00:00:00'
  GROUP BY Scans.TeileID
),
Scans20190330 AS (
  SELECT Scans.TeileID, COUNT(Scans.ID) AS AnzAuslesen
  FROM Scans
  WHERE Scans.Menge = -1
    AND Scans.DateTime < N'2019-04-01 00:00:00'
  GROUP BY Scans.TeileID
)
SELECT Teile.Barcode, Traeger.Traeger, Traeger.Vorname, Traeger.Nachname, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse, Vsa.VsaNr, Vsa.Bez AS Vsa, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, ISNULL(Scans20180330.AnzAuslesen, 0) AS [Waschzyklen bis 2018-03-30], ISNULL(Scans20190330.AnzAuslesen, 0) AS [Waschzyklen bis 2019-03-30]
FROM Teile
JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
LEFT OUTER JOIN Scans20180330 ON Scans20180330.TeileID = Teile.ID
LEFT OUTER JOIN Scans20190330 ON Scans20190330.TeileID = Teile.ID
WHERE Kunden.KdNr = 30759
  AND Abteil.Abteilung IN (N'1201021130', N'1201020800')
  AND Teile.Status IN (N'Q', N'S', N'T', N'U', N'W')
  AND Traeger.Status IN (N'A', N'K', N'P')
  AND Vsa.Status = N'A'
  AND Kunden.Status = N'A';