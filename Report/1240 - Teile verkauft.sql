SELECT KdGf.KurzBez AS Geschäftsbereich, [Zone].ZonenCode AS Vertriebszone, Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, RechKo.RechNr AS Rechnungsnummer, RechKo.RechDat AS Rechnungsdatum, Bereich.Bereich AS Produktbereich, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Teile.Barcode, Teile.AusdienstDat AS Außerdienststellungsdatum, Einsatz.EinsatzBez$LAN$ AS Ausscheidungsgrund, RechPo.EPreis AS [fakt. Wert]
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
WHERE Kunden.FirmaID IN ($2$)
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
  AND Teile.AusdienstDat BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Teile.RechPoID > 0
  AND Teile.KaufwareModus = 0;