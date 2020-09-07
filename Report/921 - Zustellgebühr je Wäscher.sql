DROP TABLE IF EXISTS #TmpLsZustell;

SELECT Produktion.Bez AS Wäscher, Produktion.SuchCode AS WäscherKurz, Artikel.ArtikelNr, Artikel.ArtikelBez, LsPo.RechPoID
INTO #TmpLsZustell
FROM LsPo
JOIN RechPo ON LsPo.RechPoID = RechPo.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Standort AS Produktion ON LsPo.ProduktionID = Produktion.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE (UPPER(Artikel.ArtikelBez) LIKE N'%ZUSTELL%' OR UPPER(Artikel.ArtikelBez) LIKE N'%ANFAHR%' OR Artikel.ArtikelNr = N'ZUS')
  AND LsPo.RechPoID > 0
  AND RechKo.RechDat BETWEEN $1$ AND $2$
GROUP BY Produktion.Bez, Produktion.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez, LsPo.RechPoID;

SELECT LsZustell.Wäscher, LsZustell.WäscherKurz, LsZustell.ArtikelNr, LsZustell.ArtikelBez, SUM(RechPo.Menge) AS Menge, SUM(RechPo.GPreis) AS Umsatz
FROM #TmpLsZustell AS LsZustell
JOIN RechPo ON LsZustell.RechPoID = RechPo.ID
GROUP BY LsZustell.Wäscher, LsZustell.WäscherKurz, LsZustell.ArtikelNr, LsZustell.ArtikelBez;