SELECT CAST(Kunden.KdNr AS nvarchar(10)) + N' ' + Kunden.SuchCode AS Kunde, Vsa.Bez AS VSA, Artikel.ArtikelNr + N' ' + Artikel.ArtikelBez AS Artikel, COUNT(Scans.ID) AS [Abwürfe 2017]
FROM Kunden
JOIN Vsa ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Teile ON Teile.ArtikelID = Artikel.ID AND Teile.VsaID = Vsa.ID
JOIN Scans ON Scans.TeileID = Teile.ID
WHERE Kunden.KdNr = 11049
  AND Artikel.ArtikelBez LIKE N'%Kälte%'
  AND YEAR(Scans.[DateTime]) = 2017
  AND Scans.ZielNrID = 1
GROUP BY CAST(Kunden.KdNr AS nvarchar(10)) + N' ' + Kunden.SuchCode, Vsa.Bez, Artikel.ArtikelNr + N' ' + Artikel.ArtikelBez;

GO