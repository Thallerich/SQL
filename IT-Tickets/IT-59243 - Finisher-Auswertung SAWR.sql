SELECT ZielNr.ZielNrBez, CAST(Scans.[DateTime] AS date) AS Datum, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, COUNT(DISTINCT Scans.TeileID) AS [Anzahl Teile]
FROM Scans
JOIN ZielNr ON Scans.ZielNrID = ZielNr.ID
JOIN Teile ON Scans.TeileID = Teile.ID
JOIN Artikel ON Teile.ArtikelID = Artikel.ID
WHERE Scans.ZielNrID IN (100000227, 100000228)
  AND Scans.[DateTime] >= N'2022-01-01 00:00:00'
GROUP BY ZielNr.ZielNrBez, CAST(Scans.[DateTime] AS date), Artikel.ArtikelNr, Artikel.ArtikelBez;