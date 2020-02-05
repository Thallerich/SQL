SELECT Produktion.Bez AS Wäscher, Produktion.SuchCode AS WäscherKurz, Artikel.ArtikelNr, Artikel.ArtikelBez, SUM(RechPo.Menge) AS Menge, SUM(RechPo.GPreis) AS Umsatz
FROM LsPo
JOIN RechPo ON LsPo.RechPoID = RechPo.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Standort AS Produktion ON LsPo.ProduktionID = Produktion.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE (UPPER(Artikel.ArtikelBez) LIKE N'%ZUSTELL%' OR UPPER(Artikel.ArtikelBez) LIKE N'%ANFAHR%')
  AND LsPo.RechPoID > 0
  AND RechKo.RechDat BETWEEN $1$ AND $2$
GROUP BY Produktion.Bez, Produktion.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez
ORDER BY Wäscher, ArtikelNr;