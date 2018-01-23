USE Wozabal
GO

SELECT DISTINCT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Artikel.ArtikelBez1 AS ArtikelbezeichnungCZ, Bereich.BereichBez AS Produktbereich, Artikel.StueckGewicht
FROM Artikel
JOIN KdArti ON KdArti.ArtikelID = Artikel.ID
JOIN LsPo ON LsPo.KdArtiID = KdArti.ID
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
WHERE KdGf.KurzBez = N'CZ'
AND LsKo.Datum >= N'2016-01-01'
AND LsPo.Menge > 0
AND Artikel.ID > 0

GO