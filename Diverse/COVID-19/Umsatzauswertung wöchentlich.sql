DECLARE @SalesWeekly TABLE (
  CalendarWeek nchar(7) COLLATE Latin1_General_CS_AS,
  CustomerID int,
  InvoiceID int,
  SalesLeasing money DEFAULT 0,
  SalesProcessing money DEFAULT 0,
  SalesOther money DEFAULT 0
);

INSERT INTO @SalesWeekly (CalendarWeek, CustomerID, InvoiceID, SalesLeasing)
SELECT Wochen.Woche, Kunden.ID AS KundenID, RechKo.ID AS RechKoID, SUM((AbtKdArW.EPreis * AbtKdArW.Menge) * (1 - RechPo.RabattProz / 100)) AS UmsatzLeasing
FROM AbtKdArW
JOIN Wochen ON AbtKdArW.WochenID = Wochen.ID
JOIN RechPo ON AbtKdArW.RechPoID = RechPo.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN Week ON RechKo.RechDat BETWEEN Week.VonDat AND Week.BisDat
WHERE RechKo.FirmaID IN (SELECT Firma.ID FROM Firma WHERE SuchCode IN (N'FA14', N'WOMI', N'UKLU'))
  AND Kunden.HoldingID != (SELECT Holding.ID FROM Holding WHERE Holding.Holding = N'SAL')
  AND Week.Woche IN (SELECT Wochen.Woche FROM Wochen WHERE Wochen.Monat1 = N'2020-04')
  AND RechKo.Status < N'X'
GROUP BY Wochen.Woche, Kunden.ID, RechKo.ID;

MERGE INTO @SalesWeekly AS SalesWeekly
USING (
  SELECT Week.Woche, Kunden.ID AS KundenID, RechKo.ID AS RechKoID, SUM(LsPo.EPreis * LsPo.Menge * (1 - RechPo.RabattProz / 100)) AS UmsatzBearbeitung
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  JOIN RechPo ON LsPo.RechPoID = RechPo.ID
  JOIN RechKo ON RechPo.RechKoID = RechKo.ID
  JOIN Kunden ON RechKo.KundenID = Kunden.ID
  JOIN Week ON RechKo.RechDat BETWEEN Week.VonDat AND Week.BisDat
  WHERE RechKo.FirmaID IN (SELECT Firma.ID FROM Firma WHERE SuchCode IN (N'FA14', N'WOMI', N'UKLU'))
    AND Kunden.HoldingID != (SELECT Holding.ID FROM Holding WHERE Holding.Holding = N'SAL')
    AND RechKo.Status < N'X'
    AND Week.Woche IN (SELECT Wochen.Woche FROM Wochen WHERE Wochen.Monat1 = N'2020-04')
  GROUP BY Week.Woche, Kunden.ID, RechKo.ID
) AS SP (Woche, KundenID, RechKoID, UmsatzBearbeitung)
ON SalesWeekly.CalendarWeek = SP.Woche AND SalesWeekly.CustomerID = SP.KundenID AND SalesWeekly.InvoiceID = SP.RechKoID
WHEN MATCHED THEN
  UPDATE SET SalesProcessing = SP.UmsatzBearbeitung
WHEN NOT MATCHED THEN
  INSERT (CalendarWeek, CustomerID, InvoiceID, SalesProcessing) VALUES (SP.Woche, SP.KundenID, SP.RechKoID, SP.UmsatzBearbeitung);

MERGE INTO @SalesWeekly AS SalesWeekly
USING (
  SELECT Week.Woche, Kunden.ID AS KundenID, RechKo.ID AS RechKoID, SUM(RechPo.GPreis) AS UmsatzAndere
  FROM RechPo
  JOIN RechKo ON RechPo.RechKoID = RechKo.ID
  JOIN Kunden ON RechKo.KundenID = Kunden.ID
  JOIN Week ON RechKo.RechDat BETWEEN Week.VonDat AND Week.BisDat
  WHERE RechKo.FirmaID IN (SELECT Firma.ID FROM Firma WHERE SuchCode IN (N'FA14', N'WOMI', N'UKLU'))
    AND Kunden.HoldingID != (SELECT Holding.ID FROM Holding WHERE Holding.Holding = N'SAL')
    AND RechKo.Status < N'X'
    AND Week.Woche IN (SELECT Wochen.Woche FROM Wochen WHERE Wochen.Monat1 = N'2020-04')
    AND RechPo.ID NOT IN (
      SELECT RechPo.ID
      FROM AbtKdArW
      JOIN Wochen ON AbtKdArW.WochenID = Wochen.ID
      JOIN RechPo ON AbtKdArW.RechPoID = RechPo.ID
      JOIN RechKo ON RechPo.RechKoID = RechKo.ID
      JOIN Week ON RechKo.RechDat BETWEEN Week.VonDat AND Week.BisDat
      WHERE RechKo.FirmaID IN (SELECT Firma.ID FROM Firma WHERE SuchCode IN (N'FA14', N'WOMI', N'UKLU'))
        AND Week.Woche IN (SELECT Wochen.Woche FROM Wochen WHERE Wochen.Monat1 = N'2020-04')
        AND RechKo.Status < N'X'
    )
    AND RechPo.ID NOT IN (
      SELECT RechPo.ID
      FROM LsPo
      JOIN LsKo ON LsPo.LsKoID = LsKo.ID
      JOIN RechPo ON LsPo.RechPoID = RechPo.ID
      JOIN RechKo ON RechPo.RechKoID = RechKo.ID
      JOIN Week ON RechKo.RechDat BETWEEN Week.VonDat AND Week.BisDat
      WHERE RechKo.FirmaID IN (SELECT Firma.ID FROM Firma WHERE SuchCode IN (N'FA14', N'WOMI', N'UKLU'))
        AND RechKo.Status < N'X'
        AND Week.Woche IN (SELECT Wochen.Woche FROM Wochen WHERE Wochen.Monat1 = N'2020-04')
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
  GROUP BY Week.Woche, Kunden.ID, RechKo.ID
) AS SO (Woche, KundenID, RechKoID, UmsatzAndere)
ON SalesWeekly.CalendarWeek = SO.Woche AND SalesWeekly.CustomerID = SO.KundenID AND SalesWeekly.InvoiceID = SO.RechKoID
WHEN MATCHED THEN
  UPDATE SET SalesOther = SO.UmsatzAndere
WHEN NOT MATCHED THEN
  INSERT (CalendarWeek, CustomerID, InvoiceID, SalesOther) VALUES (SO.Woche, SO.KundenID, SO.RechKoID, SO.UmsatzAndere);

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, RechKo.RechNr, RechKo.RechDat AS Rechnungsdatum, RechKo.Art, RechKo.NettoWert, RechKo.BruttoWert, CalendarWeek AS Woche, SalesLeasing AS Miete, SalesProcessing AS Bearbeitung, SalesOther AS Andere, SalesLeasing + SalesProcessing + SalesOther AS Wochensumme
FROM @SalesWeekly AS SW
JOIN RechKo ON SW.InvoiceID = RechKo.ID
JOIN Kunden ON SW.CustomerID = Kunden.ID
--WHERE CalendarWeek < (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat)
ORDER BY Woche ASC;