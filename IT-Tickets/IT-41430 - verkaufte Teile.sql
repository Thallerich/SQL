USE Wozabal;
GO

SELECT KdGf.KurzBez AS Geschäftsbereich, [Zone].ZonenCode AS Vertriebszone, Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, RechKo.RechNr AS Rechnungsnummer, RechKo.RechDat AS Rechnungsdatum, Bereich.Bereich AS Produktbereich, Artikel.ArtikelNr, ArtikelBez AS Artikelbezeichnung, Teile.Barcode, Teile.AusdienstDat AS Außerdienststellungsdatum, Einsatz.EinsatzBez AS Ausscheidungsgrund, RechPo.EPreis AS [fakt. Wert]
FROM Teile
JOIN RechPo ON Teile.RechPoID = RechPo.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
JOIN Artikel ON Teile.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN Einsatz ON Teile.AusdienstGrund = Einsatz.EinsatzGrund
WHERE Kunden.FirmaID = (SELECT ID FROM Firma WHERE SuchCode = N'FA14')
  AND Teile.AusdienstDat BETWEEN N'2020-01-01' AND N'2020-10-31'
  AND Teile.RechPoID > 0
  AND Teile.KaufwareModus = 0;

GO