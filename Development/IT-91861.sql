DROP TABLE IF EXISTS #OPEtiKo, #Angefordert;
GO

SELECT OPEtiKo.ID, OPEtiKo.ArtikelID, CAST(IIF(ProdHier.ProdHierBez LIKE 'Unster%', OPEtiKo.DruckZeitpunkt, OPEtiKo.PackZeitpunkt) AS date) AS ProdDatum, OPEtiKo.ProduktionID
INTO #OPEtiKo
FROM OPEtiKo
JOIN Artikel ON OPEtiKo.ArtikelID = Artikel.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN ProdHier ON Artikel.ProdHierID = ProdHier.ID
WHERE OPEtiKo.PackZeitpunkt BETWEEN N'2025-02-17' AND N'2025-03-07'
  AND OPEtiKo.ProduktionID IN (2, 4)
  AND ArtGru.SetImSet = 0;

INSERT INTO #OPEtiKo
SELECT OPEtiKo.ID, OPEtiKo.ArtikelID, CAST(IIF(ProdHier.ProdHierBez LIKE 'Unster%', OPEtiKo.DruckZeitpunkt, OPEtiKo.PackZeitpunkt) AS date) AS ProdDatum, OPEtiKo.ProduktionID
FROM OPEtiKo
JOIN Artikel ON OPEtiKo.ArtikelID = Artikel.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN ProdHier ON Artikel.ProdHierID = ProdHier.ID
WHERE OPEtiKo.DruckZeitpunkt BETWEEN N'2025-02-17' AND N'2025-03-07'
  AND OPEtiKo.ProduktionID IN (2, 4)
  AND ArtGru.SetImSet = 0
  AND NOT EXISTS (SELECT 1 FROM #OPEtiKo WHERE #OPEtiKo.ID = OPEtiKo.ID);

SELECT KdArti.ArtikelID, CAST(DATEADD(hour, TourPrio.OPSetVorlaufStd, CAST(AnfKo.Lieferdatum AS datetime2)) AS date) AS Bereitstellungsdatum, SUM(AnfPo.Angefordert) AS AnzAngefordert
INTO #Angefordert
FROM AnfPo
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN Touren ON AnfKo.TourenID = Touren.ID
JOIN TourPrio ON Touren.TourPrioID = TourPrio.ID
JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID
WHERE AnfKo.Lieferdatum BETWEEN DATEADD(day, -7, N'2025-02-17') AND DATEADD(day, 7, N'2025-03-07')
  AND AnfKo.ProduktionID IN (2, 4)
  AND KdArti.ArtikelID IN (SELECT OPSets.ArtikelID FROM OPSets)
  AND AnfPo.Angefordert != 0
GROUP BY KdArti.ArtikelID, CAST(DATEADD(hour, TourPrio.OPSetVorlaufStd, CAST(AnfKo.Lieferdatum AS datetime2)) AS date)
HAVING SUM(AnfPo.Angefordert) > 0;

GO

SELECT Artikel.ArtikelNr,
  Artikel.ArtikelBez AS Artikelbezeichnung,
  [Week].Woche,
  ISNULL(OPGepackt.AnzGepackt, 0) AS [Summe gepackt],
  CAST(ISNULL(Angefordert.AnzAngefordert, 0) AS int) AS [Summe angefordert],
  CAST(ISNULL(OPGepackt.AnzGepackt, 0) - ISNULL(Angefordert.AnzAngefordert, 0) AS int) AS Differenz,
  100 * CAST(ISNULL(OPGepackt.AnzGepackt, 0) - ISNULL(Angefordert.AnzAngefordert, 0) AS int) / CAST(IIF(ISNULL(Angefordert.AnzAngefordert, 1) = 0, 1, ISNULL(Angefordert.AnzAngefordert, 1)) AS int) AS [Abweichung in %]
FROM (
  SELECT DISTINCT OPSets.ArtikelID
  FROM OPSets
) AS OPSetsSub
CROSS JOIN [Week]
JOIN Artikel ON OPSetsSub.ArtikelID = Artikel.ID
LEFT JOIN (
  SELECT #OPEtiKo.ArtikelID, [Week].Woche, COUNT(#OPEtiKo.ID) AS AnzGepackt
  FROM #OPEtiKo
  JOIN [Week] ON #OPEtiKo.ProdDatum BETWEEN [Week].VonDat AND [Week].BisDat
  WHERE #OPEtiKo.ProdDatum BETWEEN N'2025-02-17' AND N'2025-03-07'
  GROUP BY #OPEtiKo.ArtikelID, [Week].Woche
) AS OPGepackt ON OPGepackt.ArtikelID = Artikel.ID AND OPGepackt.Woche = [Week].Woche
LEFT JOIN (
  SELECT #Angefordert.ArtikelID, [Week].Woche, SUM(#Angefordert.AnzAngefordert) AS AnzAngefordert
  FROM #Angefordert
  JOIN [Week] ON #Angefordert.Bereitstellungsdatum BETWEEN [Week].VonDat AND [Week].BisDat
  GROUP BY #Angefordert.ArtikelID, [Week].Woche
 ) AS Angefordert ON Angefordert.ArtikelID = Artikel.ID AND Angefordert.Woche = [Week].Woche
WHERE [Week].VonDat >= N'2025-02-17'
  AND [Week].BisDat <= N'2025-03-07'
  AND (OPGepackt.AnzGepackt > 0 OR Angefordert.AnzAngefordert > 0);