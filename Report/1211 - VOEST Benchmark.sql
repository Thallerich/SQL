/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Prepare Temp Table                                                                                                        ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @WocheVon nchar(7) = $3$;
DECLARE @WocheBis nchar(7) = $4$;

DROP TABLE IF EXISTS #TmpVOESTBenchmark;

SELECT Holding.Holding,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  VSA.VsaNr,
  Vsa.SuchCode AS [VSA-Stichwort],
  Vsa.Bez AS [VSA-Bezeichnung],
  Vsa.GebaeudeBez AS Abteilung,
  Abteil.Bez AS Kostenstelle,
  Wochen.Woche,
  SUM(TraeArch.Menge) AS [Teile gesamt],
  COUNT(DISTINCT TraeArti.TraegerID) AS [Träger gesamt],
  SUM(AbtKdArW.EPreis * TraeArch.Menge) AS Umsatz
INTO #TmpVOESTBenchmark
FROM AbtKdArW
JOIN TraeArch ON TraeArch.AbtKdArWID = AbtKdArW.ID
JOIN TraeArti ON TraeArch.TraeArtiID = TraeArti.ID
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
  Wochen.Woche;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Detailed Data for Benchmark                                                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT VOESTBenchmark.*, VOESTBenchmark.[Teile gesamt] / VOESTBenchmark.[Träger gesamt] AS [Durchschnitt Teile pro Träger], VOESTBenchmark.Umsatz / VOESTBenchmark.[Träger gesamt] AS [Durchschnitt Kosten pro Träger]
FROM #TmpVOESTBenchmark AS VOESTBenchmark
ORDER BY Holding, KdNr, VsaNr, Woche;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Cumulated Data for diagrams                                                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT VOESTBenchmark.Abteilung, SUM(VOESTBenchmark.[Träger gesamt]) AS [Anzahl Träger], SUM(VOESTBenchmark.Umsatz) AS [Kosten je Bereich], SUM(VOESTBenchmark.Umsatz) / SUM(VOESTBenchmark.[Träger gesamt]) AS [Durchschnitt Kosten je Träger], SUM(VOESTBenchmark.[Teile gesamt]) AS [Anzahl Kleidungstücke], SUM(VOESTBenchmark.[Teile gesamt]) / SUM(VOESTBenchmark.[Träger gesamt]) AS [Durchschnitt Teile je Träger]
FROM #TmpVOESTBenchmark AS VOESTBenchmark
GROUP BY VOESTBenchmark.Abteilung;