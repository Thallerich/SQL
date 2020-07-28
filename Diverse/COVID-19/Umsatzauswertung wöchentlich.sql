DECLARE @SalesWeekly TABLE (
  CalendarWeek nchar(7) COLLATE Latin1_General_CS_AS,
  SalesLeasing money DEFAULT 0,
  SalesProcessing money DEFAULT 0,
  SalesOther money DEFAULT 0
);

INSERT INTO @SalesWeekly (CalendarWeek, SalesLeasing)
SELECT Wochen.Woche, SUM(AbtKdArW.EPreis * AbtKdArW.Menge) AS UmsatzLeasing
FROM AbtKdArW
JOIN Wochen ON AbtKdArW.WochenID = Wochen.ID
JOIN RechPo ON AbtKdArW.RechPoID = RechPo.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
WHERE RechKo.FirmaID IN (SELECT Firma.ID FROM Firma WHERE SuchCode IN (N'FA14', N'WOMI', N'UKLU'))
  AND Kunden.HoldingID != (SELECT Holding.ID FROM Holding WHERE Holding.Holding = N'SAL')
  AND Wochen.Woche >= N'2019/01'
  AND RechKo.Status < N'X'
GROUP BY Wochen.Woche;

MERGE INTO @SalesWeekly AS SalesWeekly
USING (
  SELECT Week.Woche, SUM(LsPo.EPreis * LsPo.Menge) AS UmsatzBearbeitung
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  JOIN RechPo ON LsPo.RechPoID = RechPo.ID
  JOIN RechKo ON RechPo.RechKoID = RechKo.ID
  JOIN Kunden ON RechKo.KundenID = Kunden.ID
  JOIN Week ON LsKo.Datum BETWEEN Week.VonDat AND Week.BisDat
  WHERE RechKo.FirmaID IN (SELECT Firma.ID FROM Firma WHERE SuchCode IN (N'FA14', N'WOMI', N'UKLU'))
    AND Kunden.HoldingID != (SELECT Holding.ID FROM Holding WHERE Holding.Holding = N'SAL')
    AND RechKo.Status < N'X'
    AND Week.Woche >= N'2019/01'
  GROUP BY Week.Woche    
) AS SP (Woche, UmsatzBearbeitung)
ON SalesWeekly.CalendarWeek = SP.Woche
WHEN MATCHED THEN
  UPDATE SET SalesProcessing = SP.UmsatzBearbeitung
WHEN NOT MATCHED THEN
  INSERT (CalendarWeek, SalesProcessing) VALUES (SP.Woche, SP.UmsatzBearbeitung);

MERGE INTO @SalesWeekly AS SalesWeekly
USING (
  SELECT Week.Woche, SUM(RechPo.GPreis) AS UmsatzAndere
  FROM RechPo
  JOIN RechKo ON RechPo.RechKoID = RechKo.ID
  JOIN Kunden ON RechKo.KundenID = Kunden.ID
  JOIN Week ON RechKo.RechDat BETWEEN Week.VonDat AND Week.BisDat
  WHERE RechKo.FirmaID IN (SELECT Firma.ID FROM Firma WHERE SuchCode IN (N'FA14', N'WOMI', N'UKLU'))
    AND Kunden.HoldingID != (SELECT Holding.ID FROM Holding WHERE Holding.Holding = N'SAL')
    AND RechKo.Status < N'X'
    AND Week.Woche >= N'2019/01'
    AND RechPo.ID NOT IN (
      SELECT RechPo.ID
      FROM AbtKdArW
      JOIN Wochen ON AbtKdArW.WochenID = Wochen.ID
      JOIN RechPo ON AbtKdArW.RechPoID = RechPo.ID
      JOIN RechKo ON RechPo.RechKoID = RechKo.ID
      WHERE RechKo.FirmaID IN (SELECT Firma.ID FROM Firma WHERE SuchCode IN (N'FA14', N'WOMI', N'UKLU'))
        AND Wochen.Woche >= N'2019/01'
        AND RechKo.Status < N'X'
    )
    AND RechPo.ID NOT IN (
      SELECT RechPo.ID
      FROM LsPo
      JOIN LsKo ON LsPo.LsKoID = LsKo.ID
      JOIN RechPo ON LsPo.RechPoID = RechPo.ID
      JOIN RechKo ON RechPo.RechKoID = RechKo.ID
      JOIN Week ON LsKo.Datum BETWEEN Week.VonDat AND Week.BisDat
      WHERE RechKo.FirmaID IN (SELECT Firma.ID FROM Firma WHERE SuchCode IN (N'FA14', N'WOMI', N'UKLU'))
        AND RechKo.Status < N'X'
        AND Week.Woche >= N'2019/01'
    )
    AND NOT EXISTS (
      SELECT LsPo.*
      FROM LsPo
      WHERE LsPo.RechPoID = RechPo.ID
    )
    AND NOT EXISTS (
      SELECT AbtKdArW.*
      FROM AbtKdArW
      WHERE AbtKdArW.RechPoID = RechPo.ID
    )
  GROUP BY Week.Woche
) AS SO (Woche, UmsatzAndere)
ON SalesWeekly.CalendarWeek = SO.Woche
WHEN MATCHED THEN
  UPDATE SET SalesOther = SO.UmsatzAndere
WHEN NOT MATCHED THEN
  INSERT (CalendarWeek, SalesOther) VALUES (SO.Woche, SO.UmsatzAndere);

SELECT CalendarWeek AS Woche, SalesLeasing AS Miete, SalesProcessing AS Bearbeitung, SalesOther AS Andere, SalesLeasing + SalesProcessing + SalesOther AS Wochensumme
FROM @SalesWeekly
WHERE CalendarWeek < (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat)
ORDER BY Woche ASC;