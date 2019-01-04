SELECT CAST(DATEPART(year, RechKo.RechDat) AS nchar(4)) + IIF(DATEPART(month, RechKo.RechDat) < 10, N'-0', N'-') + CAST(DATEPART(month, RechKo.RechDat) AS nchar(2)) AS Monat, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kunden.Debitor, Bereich.BereichBez AS Produktbereich, ArtGru.ArtGruBez AS Artikelgruppe, RPoType.RpotypeBez AS Erlösart, Firma.SuchCode AS Firma, KdGf.KurzBez AS Geschäftsbereich, MwSt.MWStBez AS [MwSt-Satz], Artikel.ArtikelNr, ISNULL(Artikel.ArtikelBez, N'') AS Artikelbezeichnung, SUM(RechPo.Menge) AS [verrechnete Menge], SUM(RechPo.GPreis) AS Umsatz
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Bereich ON RechPo.BereichID = Bereich.ID
JOIN ArtGru ON RechPo.ArtGruID = ArtGru.ID
JOIN RPoType ON RechPo.RPoTypeID = RPoType.ID
JOIN Firma ON RechKo.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
JOIN MwSt ON RechKo.MWStID = MwSt.ID
WHERE RechPo.KsSt = N'2800'
  AND RechKo.FirmaID = (SELECT Firma.ID FROM Firma WHERE Firma.SuchCode = N'WOMI')
  AND RechKo.RechDat BETWEEN N'2018-04-01' AND N'2018-12-31'
  AND RechKo.FibuExpID > 0
GROUP BY CAST(DATEPART(year, RechKo.RechDat) AS nchar(4)) + IIF(DATEPART(month, RechKo.RechDat) < 10, N'-0', N'-') + CAST(DATEPART(month, RechKo.RechDat) AS nchar(2)), Kunden.KdNr, Kunden.SuchCode, Kunden.Debitor, Bereich.BereichBez, ArtGru.ArtGruBez, RPoType.RpotypeBez, Firma.SuchCode, KdGf.KurzBez, MwSt.MWStBez, Artikel.ArtikelNr, Artikel.ArtikelBez;