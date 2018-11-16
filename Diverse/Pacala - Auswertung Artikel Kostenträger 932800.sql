SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Kunden.Debitor, RechKo.RechNr, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeicnung, SUM(RechPo.Menge) AS [verrehcnete Menge], SUM(RechPo.GPreis) AS Umsatz
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE RechPo.KsSt = N'2800'
  AND RechKo.FirmaID = (SELECT Firma.ID FROM Firma WHERE Firma.SuchCode = N'UKLU')
  AND RechKo.RechDat BETWEEN N'2018-04-01' AND N'2018-06-30'
  AND RechKo.FibuExpID > 0
GROUP BY Kunden.KdNr, Kunden.SuchCode, Kunden.Debitor, RechKo.RechNr, Artikel.ArtikelNr, Artikel.ArtikelBez;