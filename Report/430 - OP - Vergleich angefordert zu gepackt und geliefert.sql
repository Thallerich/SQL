DROP TABLE IF EXISTS #OPEtiKo, #Angefordert;

SELECT OPEtiKo.ID, OPEtiKo.ArtikelID, OPEtiKo.PackZeitpunkt AS ProdDatum, OPEtiKo.ProduktionID
INTO #OPEtiKo
FROM OPEtiKo
JOIN Artikel ON OPEtiKo.ArtikelID = Artikel.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
WHERE Artikel.BereichID IN (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = N'ST')
  AND OPEtiKo.PackZeitpunkt BETWEEN $STARTDATE$ AND $ENDDATE$
  AND OPEtiKo.ProduktionID IN ($2$)
  AND ArtGru.SetImSet = 0
  AND ArtGru.Steril = 1;

SELECT KdArti.ArtikelID, CAST(DATEADD(hour, TourPrio.OPSetVorlaufStd, CAST(AnfKo.Lieferdatum AS datetime2)) AS date) AS Bereitstellungsdatum, SUM(AnfPo.Angefordert) AS AnzAngefordert, SUM(AnfPo.Geliefert) AS AnzGeliefert
INTO #Angefordert
FROM AnfPo
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN Touren ON AnfKo.TourenID = Touren.ID
JOIN TourPrio ON Touren.TourPrioID = TourPrio.ID
JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
WHERE AnfKo.Lieferdatum BETWEEN DATEADD(day, -7, $STARTDATE$) AND DATEADD(day, 7, $ENDDATE$)
  AND AnfKo.ProduktionID IN ($2$)
  AND Artikel.ID IN (SELECT OPSets.ArtikelID FROM OPSets)
  AND Artikel.BereichID IN (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = N'ST')
  AND ArtGru.Steril = 1
  AND AnfPo.Angefordert != 0
GROUP BY KdArti.ArtikelID, CAST(DATEADD(hour, TourPrio.OPSetVorlaufStd, CAST(AnfKo.Lieferdatum AS datetime2)) AS date)
HAVING SUM(AnfPo.Angefordert) > 0;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  [Week].Woche,
  ISNULL(OPGepackt.AnzGepackt, 0) AS [Summe gepackt],
  CAST(ISNULL(Angefordert.AnzAngefordert, 0) AS int) AS [Summe angefordert],
  CAST(ISNULL(Angefordert.AnzGeliefert, 0) AS int) AS [Summe geliefert],
  CAST(ISNULL(OPGepackt.AnzGepackt, 0) - ISNULL(Angefordert.AnzAngefordert, 0) AS int) AS [Differenz gepackt zu angefordert],
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
  WHERE #OPEtiKo.ProdDatum BETWEEN $STARTDATE$ AND $ENDDATE$
  GROUP BY #OPEtiKo.ArtikelID, [Week].Woche
) AS OPGepackt ON OPGepackt.ArtikelID = Artikel.ID AND OPGepackt.Woche = [Week].Woche
LEFT JOIN (
  SELECT #Angefordert.ArtikelID, [Week].Woche, SUM(#Angefordert.AnzAngefordert) AS AnzAngefordert, SUM(#Angefordert.AnzGeliefert) AS AnzGeliefert
  FROM #Angefordert
  JOIN [Week] ON #Angefordert.Bereitstellungsdatum BETWEEN [Week].VonDat AND [Week].BisDat
  GROUP BY #Angefordert.ArtikelID, [Week].Woche
 ) AS Angefordert ON Angefordert.ArtikelID = Artikel.ID AND Angefordert.Woche = [Week].Woche
WHERE [Week].BisDat >= $STARTDATE$
  AND [Week].VonDat <= $ENDDATE$
  AND (OPGepackt.AnzGepackt > 0 OR Angefordert.AnzAngefordert > 0);