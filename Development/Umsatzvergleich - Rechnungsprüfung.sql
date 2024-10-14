DROP TABLE IF EXISTS #RechKo;
GO

SELECT RechKo.ID AS RechKoID, RechKo.RechDat, RechKo.FirmaID, RechKo.KundenID, RechKo.MasterWochenID, RechKo.NettoWert, RechKo.BruttoWert, RechKo.MwStBetrag, RechKo.RechWaeID, TopFakPer = (
  SELECT TOP 1 FakFreq.AnzPerioden + IIF(FakPer.PlusWochen = 0, FakPer.PlusMonate, FakPer.PlusWochen) - 1 AS AnzPerioden
  FROM KdBer
  JOIN FakFreq ON KdBer.FakFreqID = FakFreq.ID
  JOIN FakPer ON FakFreq.FakPerID = FakPer.ID
  WHERE KdBer.KundenID = RechKo.KundenID
    AND KdBer.ID IN (
      SELECT RechPo.KdBerID
      FROM RechPo
      WHERE RechPo.RechKoID = RechKo.ID
    )
  GROUP BY KdBer.KundenID, FakFreq.AnzPerioden + IIF(FakPer.PlusWochen = 0, FakPer.PlusMonate, FakPer.PlusWochen) - 1
  ORDER BY COUNT(KdBer.ID) DESC
),
TopFakPerType = (
  SELECT TOP 1 IIF(FakFreq.ID = -1, N'Standard', IIF(FakPer.PlusWochen = 0, N'Monat', N'Woche')) AS PeriodenType
  FROM KdBer
  JOIN FakFreq ON KdBer.FakFreqID = FakFreq.ID
  JOIN FakPer ON FakFreq.FakPerID = FakPer.ID
  WHERE KdBer.KundenID = RechKo.KundenID
    AND KdBer.ID IN (
      SELECT RechPo.KdBerID
      FROM RechPo
      WHERE RechPo.RechKoID = RechKo.ID
    )
  GROUP BY KdBer.KundenID, IIF(FakFreq.ID = -1, N'Standard', IIF(FakPer.PlusWochen = 0, N'Monat', N'Woche'))
  ORDER BY COUNT(KdBer.ID) DESC
)
INTO #RechKo
FROM RechKo
WHERE RechKo.FirmaID = (SELECT Firma.ID FROM Firma WHERE Firma.SuchCode = N'SMRO')
  AND RechKo.[Status] < N'X'
  AND RechKo.RechDat = N'2024-09-30';

GO

SELECT Firma.SuchCode AS FirmenNr,
  Firma.Bez AS Firma,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  IIF(RechKo.TopFakPerType = N'Standard', N'Monatlich', IIF(RechKo.TopFakPerType = N'Woche', FORMAT(TopFakPer, N'N0') + N'-wöchentlich', FORMAT(TopFakPer, N'N0') + N'-monatlich')) AS Berechnungslauf,
  IIF(RechKo.TopFakPerType = N'Standard',
    FORMAT(DATEADD(month, DATEDIFF(month, 0, RechKo.RechDat), 0), 'dd.MM.yyyy') + N' - ' + FORMAT(RechKo.RechDat, 'dd.MM.yyyy'),
    IIF(RechKo.TopFakPerType = N'Woche',
      FORMAT(DATEADD(day, 1, DATEADD(week, -1 * RechKo.TopFakPer, [Week].BisDat)), 'dd.MM.yyyy') + N' - ' + FORMAT([Week].BisDat, 'dd.MM.yyyy'),
      FORMAT(DATEADD(day, 1, DATEADD(month, -1 * RechKo.TopFakPer, [Week].BisDat)), 'dd.MM.yyyy') + N' - ' + FORMAT([Week].BisDat, 'dd.MM.yyyy')
    )
  ) AS Periode,
  SUM(RechKo.BruttoWert) AS Brutto,
  RechKo.RechWaeID AS Brutto_WaeID,
  SUM(RechKo.NettoWert) AS Netto,
  RechKo.RechWaeID AS Netto_WaeID,
  SUM(RechKo.MwStBetrag) AS MwSt,
  RechKo.RechWaeID AS MwSt_WaeID,
  NULL AS [Differenz zu Vormonat Brutto],
  NULL AS [Differenz Brutto %],
  NULL AS [Differenz zu Vormonat Netto],
  NULL AS [Differenz Netto %]
FROM #RechKo AS RechKo
JOIN Firma ON RechKo.FirmaID = Firma.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN Wochen ON RechKo.MasterWochenID = Wochen.ID
JOIN [Week] ON Wochen.Woche = [Week].Woche
GROUP BY Firma.SuchCode,
  Firma.Bez,
  Kunden.KdNr,
  Kunden.SuchCode,
  IIF(RechKo.TopFakPerType = N'Standard', N'Monatlich', IIF(RechKo.TopFakPerType = N'Woche', FORMAT(TopFakPer, N'N0') + N'-wöchentlich', FORMAT(TopFakPer, N'N0') + N'-monatlich')),
  IIF(RechKo.TopFakPerType = N'Standard',
    FORMAT(DATEADD(month, DATEDIFF(month, 0, RechKo.RechDat), 0), 'dd.MM.yyyy') + N' - ' + FORMAT(RechKo.RechDat, 'dd.MM.yyyy'),
    IIF(RechKo.TopFakPerType = N'Woche',
      FORMAT(DATEADD(day, 1, DATEADD(week, -1 * RechKo.TopFakPer, [Week].BisDat)), 'dd.MM.yyyy') + N' - ' + FORMAT([Week].BisDat, 'dd.MM.yyyy'),
      FORMAT(DATEADD(day, 1, DATEADD(month, -1 * RechKo.TopFakPer, [Week].BisDat)), 'dd.MM.yyyy') + N' - ' + FORMAT([Week].BisDat, 'dd.MM.yyyy')
    )
  ),
  RechKo.RechWaeID;

GO