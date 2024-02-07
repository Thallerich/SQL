DECLARE @customer TABLE (
  customerid int,
  customername nvarchar(20),
  amountchip int,
  amountnonchip int,
  percentagechipped AS (100 / (amountchip + amountnonchip) * amountchip)
)

INSERT INTO @customer (customerid, customername, amountchip, amountnonchip)
SELECT Kunden.KdNr AS customerid, Kunden.SuchCode AS customername, SUM(IIF(LEN(EinzHist.Barcode) = 24 OR LEN(EinzHist.RentomatChip) = 24, 1, 0)) AS amountchip, SUM(IIF(LEN(EinzHist.Barcode) != 24 AND LEN(EinzHist.RentomatChip) != 24, 1, 0)) AS amountnonchip
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN Kunden ON EinzHist.KundenID = Kunden.ID
WHERE Kunden.[Status] = N'A'
  AND Kunden.AdrArtID = 1
  AND EinzTeil.LastScanTime > DATEADD(year, -1, GETDATE())
  AND EinzHist.EinzHistTyp = 1
GROUP BY Kunden.KdNr, Kunden.SuchCode
HAVING SUM(IIF(LEN(EinzHist.Barcode) = 24 OR LEN(EinzHist.RentomatChip) = 24, 1, 0)) > 0 OR SUM(IIF(LEN(EinzHist.Barcode) != 24 AND LEN(EinzHist.RentomatChip) != 24, 1, 0)) > 0;

SELECT customerid, CAST(IIF(percentagechipped > 50, 1, 0) AS bit) AS chipcoded
FROM @customer;