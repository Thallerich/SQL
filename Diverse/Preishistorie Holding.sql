USE Wozabal
GO

DROP TABLE IF EXISTS #TmpPreis1, #TmpPreis2, #TmpPreis3;

GO

SELECT PrArchiv.KdArtiID, PrArchiv.LeasingPreis, PrArchiv.WaschPreis
INTO #TmpPreis1
FROM PrArchiv, (
  SELECT PrArchiv.KdArtiID, MAX(PrArchiv.ID) AS PrArchivID
  FROM PrArchiv, KdArti, Kunden, Holding
  WHERE PrArchiv.KdArtiID = KdArti.ID
  AND KdArti.KundenID = Kunden.ID
  AND Kunden.HoldingID = Holding.ID
  AND Holding.Holding = N'GESPAG'
  AND PrArchiv.Datum < N'2017-01-01'
  GROUP BY PrArchiv.KdArtiID
) AS P15
WHERE P15.PrArchivID = PrArchiv.ID;

SELECT PrArchiv.KdArtiID, PrArchiv.LeasingPreis, PrArchiv.WaschPreis
INTO #TmpPreis2
FROM PrArchiv, (
  SELECT PrArchiv.KdArtiID, MAX(PrArchiv.ID) AS PrArchivID
  FROM PrArchiv, KdArti, Kunden, Holding
  WHERE PrArchiv.KdArtiID = KdArti.ID
  AND KdArti.KundenID = Kunden.ID
  AND Kunden.HoldingID = Holding.ID
  AND Holding.Holding = N'GESPAG'
  AND PrArchiv.Datum < N'2018-01-01'
  GROUP BY PrArchiv.KdArtiID
) AS P16
WHERE P16.PrArchivID = PrArchiv.ID;

SELECT PrArchiv.KdArtiID, PrArchiv.LeasingPreis, PrArchiv.WaschPreis
INTO #TmpPreis3
FROM PrArchiv, (
  SELECT PrArchiv.KdArtiID, MAX(PrArchiv.ID) AS PrArchivID
  FROM PrArchiv, KdArti, Kunden, Holding
  WHERE PrArchiv.KdArtiID = KdArti.ID
  AND KdArti.KundenID = Kunden.ID
  AND Kunden.HoldingID = Holding.ID
  AND Holding.Holding = N'GESPAG'
  AND PrArchiv.Datum < N'2019-01-01'
  GROUP BY PrArchiv.KdArtiID
) AS P17
WHERE P17.PrArchivID = PrArchiv.ID;

SELECT Bereich.Bereich, Bereich.BereichBez AS Artikelbereich, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, CONVERT(money, ISNULL(Preis1.LeasingPreis, 0), 2) AS Leasing2016, CONVERT(money, ISNULL(Preis1.WaschPreis, 0), 2) AS WaschPreis2016, CONVERT(money, ISNULL(Preis2.LeasingPreis, 0), 2) AS Leasing2017, CONVERT(money, ISNULL(Preis2.WaschPreis, 0), 2) AS WaschPreis2017, CONVERT(money, ISNULL(Preis3.LeasingPreis, 0), 2) AS Leasing2018, CONVERT(money, ISNULL(Preis3.WaschPreis, 0), 2) AS WaschPreis2018
FROM Artikel, Bereich, Kunden, Holding, KdArti
LEFT OUTER JOIN #TmpPreis1 AS Preis1 ON Preis1.KdArtiID = KdArti.ID
LEFT OUTER JOIN #TmpPreis2 AS Preis2 ON Preis2.KdArtiID = KdArti.ID
LEFT OUTER JOIN #TmpPreis3 AS Preis3 ON Preis3.KdArtiID = KdArti.ID
WHERE KdArti.ArtikelID = Artikel.ID
AND KdArti.KundenID = Kunden.ID
AND Kunden.HoldingID = Holding.ID
AND Holding.Holding = N'GESPAG'
AND Artikel.BereichID = Bereich.ID
AND KdArti.Status = N'A'
AND Kunden.Status = N'A'
AND Artikel.Status < N'I'
AND Artikel.ID > 0
GROUP BY Bereich.Bereich, Bereich.BereichBez, Artikel.ArtikelNr, Artikel.ArtikelBez, CONVERT(money, ISNULL(Preis1.LeasingPreis, 0), 2), CONVERT(money, ISNULL(Preis1.WaschPreis, 0), 2), CONVERT(money, ISNULL(Preis2.LeasingPreis, 0), 2), CONVERT(money, ISNULL(Preis2.WaschPreis, 0), 2), CONVERT(money, ISNULL(Preis3.LeasingPreis, 0), 2), CONVERT(money, ISNULL(Preis3.WaschPreis, 0), 2)
ORDER BY Artikelbezeichnung;

GO