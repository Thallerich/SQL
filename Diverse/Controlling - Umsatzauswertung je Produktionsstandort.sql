SELECT Standort.SuchCode AS Wäscher, Firma.SuchCode AS Firma, Holding.Holding, Kunden.Debitor, Kunden.SuchCode AS Kunde, ArtGru.ArtGruBez AS Artikelgruppe, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, SUM(IIF(RechPo.RPoTypeID IN (1, 2, 8, 9, 14, 15, 26, 35), RechPo.GPreis, 0)) AS Umsatz
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGru ON RechPo.ArtGruID = ArtGru.ID
JOIN Vsa ON RechPo.VsaID = Vsa.ID
JOIN KdBer ON RechPo.KdBerID = KdBer.ID
JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = KdBer.BereichID
JOIN Standort ON StandBer.ProduktionID = Standort.ID
JOIN Firma ON RechKo.FirmaID = Firma.ID
WHERE RechKo.EffektivBis BETWEEN N'2019-10-01' AND N'2019-10-31'
  AND RechKo.Status < N'X'
GROUP BY Standort.SuchCode, Firma.SuchCode, Holding.Holding, Kunden.Debitor, Kunden.SuchCode, ArtGru.ArtGruBez, Artikel.ArtikelNr, Artikel.ArtikelBez;