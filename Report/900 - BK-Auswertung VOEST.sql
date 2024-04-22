/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: DropTemp - vorbereitend                                                                                         ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #TmpVOEST;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: InitTemp - vorbereitend                                                                                         ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

CREATE TABLE #TmpVOEST (
  Holding nvarchar(40) COLLATE Latin1_General_CS_AS,
  KdNr int,
  Kunde nvarchar(20) COLLATE Latin1_General_CS_AS,
  RechnungsNr int,
  Rechnungsdatum date,
  VsaNr int,
  [VSA-Stichwort] nvarchar(40) COLLATE Latin1_General_CS_AS,
  [VSA-Bezeichnung] nvarchar(40) COLLATE Latin1_General_CS_AS,
  Woche nchar(7) COLLATE Latin1_General_CS_AS,
  [Teile gesamt] int,
  [Träger gesamt] int,
  [Umsatz VSA] money
);

INSERT INTO #TmpVOEST
SELECT Holding.Bez AS Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, RechKo.RechNr AS RechnungsNr, RechKo.RechDat AS Rechnungsdatum, Vsa.VsaNr, Vsa.SuchCode AS [VSA-Stichwort], Vsa.Bez AS [VSA-Bezeichnung], Wochen.Woche, SUM(TraeArch.Menge) AS [Teile gesamt], COUNT(DISTINCT Traeger.ID) AS [Träger gesamt], SUM(AbtKdArW.WoPa) AS [Umsatz VSA]
FROM TraeArch
JOIN AbtKdArW ON TraeArch.AbtKdArWID = AbtKdArW.ID
JOIN RechPo ON AbtKdArW.RechPoID = RechPo.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Wochen ON AbtKdArW.WochenID = Wochen.ID
JOIN TraeArti ON TraeArch.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON TraeArch.VsaID = Vsa.ID
JOIN Kunden ON TraeArch.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
WHERE RechKo.RechDat BETWEEN $1$ AND $2$
  AND RechKo.Status >= N'N'
  AND RechKo.Status < N'X'
  AND Kunden.ID = $ID$
GROUP BY Holding.Bez, Kunden.KdNr, Kunden.SuchCode, RechKo.RechNr, RechKo.RechDat, Vsa.VsaNr, Vsa.SuchCode, Vsa.Bez, Wochen.Woche;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: Reportdaten                                                                                                     ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Voest.Holding, Voest.KdNr, Voest.Kunde, Voest.RechnungsNr, Voest.Rechnungsdatum, Voest.VsaNr, Voest.[VSA-Stichwort], Voest.[VSA-Bezeichnung], Voest.Woche, Voest.[Teile gesamt], Voest.[Träger gesamt], Voest.[Umsatz VSA], Voest.[Teile gesamt] / Voest.[Träger gesamt] AS [Durchschnitt Teile pro Träger], Voest.[Umsatz VSA] / Voest.[Träger gesamt] AS [Durchschnitt Kosten pro Träger]
FROM #TmpVOEST AS Voest
ORDER BY Voest.Holding, Voest.KdNr, Voest.VsaNr, Voest.Woche;