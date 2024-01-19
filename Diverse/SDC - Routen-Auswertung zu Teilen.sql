USE Salesianer_Lenzing_1
GO

WITH EinzHistStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZHIST'
)
SELECT SdcProdX.Barcode,
  SdcProdX.Chipcode AS Bügelcode,
  EinzHistStatus.StatusBez AS [aktueller Teile-Status],
  Ort1.Bez + N' (' + Ort1.SortOrt + N')' AS [Route Ort 1],
  Ort2.Bez + N' (' + Ort2.SortOrt + N')' AS [Route Ort 2],
  Ort3.Bez + N' (' + Ort3.SortOrt + N')' AS [Route Ort 3],
  Ort4.Bez + N' (' + Ort4.SortOrt + N')' AS [Route Ort 4],
  [Aufbügel-TCP] = (SELECT TOP 1 SdcTcpL.[Message] FROM SdcTcpL WHERE SdcTcpL.Barcode = SdcProdX.Barcode AND SdcTcpL.TransNr = '611' ORDER BY ID DESC),
  [Zeitpunkt Aufbügeln] = (SELECT TOP 1 SdcTcpL.Anlage_ FROM SdcTcpL WHERE SdcTcpL.Barcode = SdcProdX.Barcode AND SdcTcpL.TransNr = '611' ORDER BY ID DESC)
FROM (
  SELECT SdcProd.*, RANK() OVER (PARTITION BY SdcProd.EinzHistID ORDER BY SdcProd.ID DESC) AS SortRank
  FROM SdcProd
  JOIN EinzHist ON SdcProd.EinzHistID = EinzHist.ID
  WHERE EinzHist.Barcode IN ('1026275205', '2066382182', '2066371995')
) SdcProdX
JOIN SdcOrte AS Ort1 ON SdcProdX.RouteOrt1ID = Ort1.ID
JOIN SdcOrte AS Ort2 ON SdcProdX.RouteOrt2ID = Ort2.ID
JOIN SdcOrte AS Ort3 ON SdcProdX.RouteOrt3ID = Ort3.ID
JOIN SdcOrte AS Ort4 ON SdcProdX.RouteOrt4ID = Ort4.ID
JOIN EinzHist ON SdcProdX.EinzHistID = EinzHist.ID
JOIN EinzHistStatus ON EinzHist.[Status] = EinzHistStatus.[Status]
WHERE SdcProdX.SortRank = 1

GO