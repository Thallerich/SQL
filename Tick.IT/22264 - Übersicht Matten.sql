USE Wozabal
GO

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Mitarbei.[Name] AS Fahrer, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, SUM(LsPo.Menge) AS Menge
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN LsKoArt ON LsKo.LsKoArtID = LsKoArt.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN Fahrt ON LsKo.FahrtID = Fahrt.ID
JOIN Mitarbei ON Fahrt.MitarbeiID = Mitarbei.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE LsKo.Datum BETWEEN N'2017-12-04' AND N'2017-12-10'
  AND LsKoArt.Art = N'M'
  AND Bereich.Bereich = N'MA'
GROUP BY Kunden.KdNr, Kunden.SuchCode, Mitarbei.[Name], Artikel.ArtikelNr, Artikel.ArtikelBez

GO