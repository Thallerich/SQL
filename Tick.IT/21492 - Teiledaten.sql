USE Wozabal
GO

SELECT Teile.Barcode, Status.StatusBez AS Teilestatus, Firma.Bez AS Firma, KdGf.KurzBez AS SGF, Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Bereich.BereichBez AS Produktbereich, FORMAT(Teile.IndienstDat, 'd', 'de-AT') AS Indienststellungsdatum, Teile.EKGrundAkt AS EKAktuell, IIF(Teile.Ausdienst IS NOT NULL, Teile.AusdRestw, Teile.RestwertInfo) AS Restwert
FROM Teile
JOIN KdArti ON Teile.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Vsa ON Teile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Status ON Teile.Status = Status.Status AND Status.Tabelle = N'TEILE'
WHERE Teile.Status IN (N'Q', N'S', N'U', N'W')
AND KdGf.KurzBez = N'HO'
--AND Holding.Holding LIKE N'GESPAG%'
--AND Kunden.KdNr < 10000
AND Kunden.Status = N'A'
AND Vsa.Status = N'A'
AND Firma.SuchCode <> N'42'
ORDER BY SGF, KdNr, ArtikelNr

GO