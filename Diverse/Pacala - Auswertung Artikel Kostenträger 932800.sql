SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Kunden.Debitor, Artikel.ArtikelNr, ISNULL(Artikel.ArtikelBez, N'') AS Artikelbezeichnung, SUM(RechPo.Menge) AS [verrechnete Menge], SUM(RechPo.GPreis) AS Umsatz
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE RechPo.KsSt = N'2800'
  AND RechKo.FirmaID = (SELECT Firma.ID FROM Firma WHERE Firma.SuchCode = N'WOMI')
  AND RechKo.RechDat BETWEEN N'2018-04-01' AND N'2018-10-31'
  AND RechKo.FibuExpID > 0
GROUP BY Kunden.KdNr, Kunden.SuchCode, Kunden.Debitor, Artikel.ArtikelNr, Artikel.ArtikelBez;