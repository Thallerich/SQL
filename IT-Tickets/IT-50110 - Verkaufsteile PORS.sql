SELECT Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, Traeger.Traeger, Traeger.Nachname, Traeger.Vorname, Teile.Barcode, Teile.Ausgang1 AS Lieferdatum, IIF(RechKo.ID < 0, NULL, RechKo.RechNr) AS RechNr, IIF(RechPo.ID < 0, NULL, RechPo.EPreis) AS EPreis, Artikel.ArtikelNr, Artikel.ArtikelBez, KdArti.VkPreis, LsKo.LsNr, LsKo.Datum AS [Lieferschein-Datum], LsKoArt.Art AS [Lieferschein-Art]
FROM Teile
JOIN Traeger ON Teile.TraegerID = Traeger.ID
JOIN KdArti ON Teile.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN RwConfPo ON Kunden.RWConfigID = RwConfPo.RwConfigID AND RwConfPo.RwArtID = 6
JOIN LsPo ON Teile.LastLsPoID = LsPo.ID
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN LsKoArt ON LsKo.LsKoArtID = LsKoArt.ID
JOIN RechPo ON Teile.RechPoID = RechPo.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
WHERE Firma.SuchCode = N'FA14'
  AND Teile.Status = N'Z'
  AND Teile.Ausgang1 >= N'2021-06-01'
  AND Holding.Holding = N'PORS';