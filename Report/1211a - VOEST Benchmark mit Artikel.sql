/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Prepare Temp Table                                                                                                        ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @WocheVon nchar(7) = $3$;
DECLARE @WocheBis nchar(7) = $4$;

DROP TABLE IF EXISTS #TmpVOESTBenchmarkArtikel;

SELECT Holding.Holding,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  VSA.VsaNr,
  Vsa.SuchCode AS [VSA-Stichwort],
  Vsa.Bez AS [VSA-Bezeichnung],
  Vsa.GebaeudeBez AS Abteilung,
  Abteil.Bez AS Kostenstelle,
  Wochen.Woche,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez AS Artikelbezeichnung,
  SUM(TraeArch.Menge) AS [Teile gesamt],
  COUNT(DISTINCT TraeArti.TraegerID) AS [Träger gesamt]
INTO #TmpVOESTBenchmarkArtikel
FROM AbtKdArW
JOIN TraeArch ON TraeArch.AbtKdArWID = AbtKdArW.ID
JOIN TraeArti ON TraeArch.TraeArtiID = TraeArti.ID
JOIN KdArti ON AbtKdArW.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Vsa ON AbtKdArW.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Abteil ON AbtKdArW.AbteilID = Abteil.ID
JOIN Wochen ON AbtKdArW.WochenID = Wochen.ID
WHERE Holding.ID IN ($1$)
  AND Kunden.ID IN ($2$)
  AND Wochen.Woche BETWEEN @WocheVon AND @WocheBis
GROUP BY Holding.Holding,
  Kunden.KdNr,
  Kunden.SuchCode,
  Vsa.VsaNr,
  Vsa.SuchCode,
  Vsa.Bez,
  Vsa.GebaeudeBez,
  Abteil.Bez,
  Wochen.Woche,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Detailed Data for Benchmark                                                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT VOESTBenchmark.*, ROUND(CAST(VOESTBenchmark.[Teile gesamt] AS float) / CAST(VOESTBenchmark.[Träger gesamt] AS float), 0) AS [Durchschnitt Teile pro Träger]
FROM #TmpVOESTBenchmarkArtikel AS VOESTBenchmark
ORDER BY Holding, KdNr, VsaNr, Woche;