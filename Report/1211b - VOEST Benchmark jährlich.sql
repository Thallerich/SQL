/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Prepare Temp Table                                                                                                        ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @WocheVon nchar(7) = $3$;
DECLARE @WocheBis nchar(7) = $4$;

DECLARE @YearVon int = CAST(LEFT(@WocheVon, 4) AS int);
DECLARE @YearBis int = CAST(LEFT(@WocheBis, 4) AS int);

DECLARE @RechPeriode TABLE (
  RechKoID int,
  Jahr int,
  Rechnungsperiode int
);

INSERT INTO @RechPeriode
SELECT RechKo.ID AS RechKoID, DATEPART(year, RechKo.RechDat) AS Jahr, DENSE_RANK() OVER (PARTITION BY DATEPART(year, Rechko.RechDat) ORDER BY RechKo.RechDat) AS Rechnungsperiode
FROM RechKo
WHERE RechKo.KundenID IN ($2$)
  AND DATEPART(year, RechKo.RechDat) BETWEEN @YearVon AND @YearBis
  AND EXISTS (
    SELECT RechPo.ID
    FROM RechPo
    JOIN AbtKdArW ON AbtKdArW.RechPoID = RechPo.ID
    JOIN TraeArch ON TraeArch.AbtKdArWID = AbtKdArW.ID
    WHERE RechPo.RechKoID = RechKo.ID
  );

UPDATE @RechPeriode SET Rechnungsperiode = Rechnungsperiode + 6
WHERE Jahr = 2019;

SELECT * FROM @RechPeriode;

DROP TABLE IF EXISTS #TmpVOESTBenchmark;

SELECT 
  Holding.Holding,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  RechKo.RechNr,
  RechKo.RechDat,
  CAST(RechPeriode.Jahr AS nvarchar) + '/' + RIGHT(N'0' + CAST(RechPeriode.Rechnungsperiode AS nvarchar), 2) AS Rechnungsperiode,
  Vsa.VsaNr,
  Vsa.SuchCode AS [VSA-Stichwort],
  Vsa.Bez AS [VSA-Bezeichnung],
  Vsa.GebaeudeBez AS Abteilung,
  Vsa.Name2 AS Bereich,
  Abteil.Bez AS Kostenstelle,
  Wochen.Woche,
  RechPo.Menge as RGMenge,
  SUM(TraeArch.Menge) AS [Teile gesamt],
  COUNT(DISTINCT TraeArti.TraegerID) AS [Träger gesamt],
  SUM(AbtKdArW.EPreis * TraeArch.Menge) AS Umsatz
INTO #TmpVOESTBenchmark
FROM AbtKdArW
JOIN TraeArch ON TraeArch.AbtKdArWID = AbtKdArW.ID
JOIN TraeArti ON TraeArch.TraeArtiID = TraeArti.ID
JOIN Vsa ON AbtKdArW.VsaID = Vsa.ID
JOIN Kunden ON Traearch.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Abteil ON AbtKdArW.AbteilID = Abteil.ID
JOIN Wochen ON AbtKdArW.WochenID = Wochen.ID
JOIN RechPo ON AbtKdArW.RechPoID = RechPo.ID
JOIN RechKo ON RechKo.ID = RechPo.RechKoID
JOIN @RechPeriode AS RechPeriode ON RechPeriode.RechKoID = RechKo.ID
WHERE Holding.ID IN ($1$)
  AND Kunden.ID IN ($2$)
  AND Wochen.Woche BETWEEN @WocheVon AND @WocheBis
  AND AbtKdArW.RechPoID > 0
GROUP BY Holding.Holding,
  Kunden.KdNr,
  Kunden.SuchCode,
  RechKo.RechNr,
  RechKo.RechDat,
  CAST(RechPeriode.Jahr AS nvarchar) + '/' + RIGHT(N'0' + CAST(RechPeriode.Rechnungsperiode AS nvarchar), 2),
  Vsa.VsaNr,
  Vsa.SuchCode,
  Vsa.Bez,
  Vsa.Name2,
  RechPo.ID,
  Vsa.GebaeudeBez,
  Abteil.Bez,
  RechPo.Menge,
  Wochen.Woche,
  RechKo.Rechnr,
  Rechko.RechDat,
  RechKo.VonDatum,
  RechKo.BisDatum;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Detailed Data for Benchmark                                                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT VOESTBenchmark.*, VOESTBenchmark.[Teile gesamt] / VOESTBenchmark.[Träger gesamt] AS [Durchschnitt Teile pro Träger], VOESTBenchmark.Umsatz / VOESTBenchmark.[Träger gesamt] AS [Durchschnitt Kosten pro Träger]
FROM #TmpVOESTBenchmark AS VOESTBenchmark
ORDER BY Rechnungsperiode, Holding, KdNr, VsaNr;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Cumulated Data for diagrams                                                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT VOESTBenchmark.Rechnungsperiode, VOESTBenchmark.RechNr, VOESTBenchmark.RechDat, VOESTBenchmark.Abteilung, VOESTBenchmark.Bereich, VOESTBenchmark.Kostenstelle, MAX(VOESTBenchmark.[Träger gesamt]) AS [Anzahl Träger], SUM(VOESTBenchmark.Umsatz) AS [Kosten je Bereich], SUM(VOESTBenchmark.Umsatz) / MAX(VOESTBenchmark.[Träger gesamt]) AS [Durchschnitt Kosten je Träger], MAX(VOESTBenchmark.[Teile gesamt]) AS [Anzahl Kleidungstücke], MAX(VOESTBenchmark.[Teile gesamt]) / MAX(VOESTBenchmark.[Träger gesamt]) AS [Durchschnitt Teile je Träger]
FROM #TmpVOESTBenchmark AS VOESTBenchmark
GROUP BY VOESTBenchmark.Rechnungsperiode, VOESTBenchmark.RechNr, VOESTBenchmark.RechDat, VOESTBenchmark.Abteilung, VOESTBenchmark.Bereich, VOESTBenchmark.Kostenstelle
ORDER BY Rechnungsperiode, Abteilung;