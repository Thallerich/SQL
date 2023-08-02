USE Salesianer_SA22;
GO

SELECT SdcProd.Barcode, SdcProd.Ready, OL.SortOrt + N' (' + OL.Bez + N')' AS [Letzter Ort], O1.SortOrt + N' (' + O1.Bez + N')' AS [Route Ort 1], O2.SortOrt + N' (' + O2.Bez + N')' AS [Route Ort 2], O3.SortOrt + N' (' + O3.Bez + N')' AS [Route Ort 3], O4.SortOrt + N' (' + O4.Bez + N')' AS [Route Ort 4], SdcProd.EinDat, SdcProd.AusDat, SdcProd.SortText, SdcProd.Anlage_
FROM SdcProd
JOIN SdcOrte O1 ON SdcProd.RouteOrt1ID = O1.ID
JOIN SdcOrte O2 ON SdcProd.RouteOrt2ID = O2.ID
JOIN SdcOrte O3 ON SdcProd.RouteOrt3ID = O3.ID
JOIN SdcOrte O4 ON SdcProd.RouteOrt4ID = O4.ID
JOIN SdcOrte OL ON SdcProd.OrtID = OL.ID
WHERE SdcProd.EinzHistID = (SELECT ID FROM EinzHist WHERE Barcode = N'2066992961' AND IsCurrEinzHist = 1);

GO

SELECT SdcRoute.Kategorie, SdcRoute.KeyValue, SdcRoute.Bez, IIF(O1.ID < 0, NULL, O1.SortOrt + N' (' + O1.Bez + N')') AS [Ort 1], SdcRoute.AlwaysUseOrt1 AS [übersteuert?], IIF(O2.ID < 0, NULL, O2.SortOrt + N' (' + O2.Bez + N')') AS [Ort 2], SdcRoute.AlwaysUseOrt2 AS [übersteuert?], IIF(O3.ID < 0, NULL, O3.SortOrt + N' (' + O3.Bez + N')') AS [Ort 3], SdcRoute.AlwaysUseOrt3 AS [übersteuert?], IIF(O4.ID < 0, NULL, O4.SortOrt + N' (' + O4.Bez + N')') AS [Ort 4], SdcRoute.AlwaysUseOrt4 AS [übersteuert?]
FROM SdcRoute
JOIN SdcOrte O1 ON SdcRoute.Ort1ID = O1.ID
JOIN SdcOrte O2 ON SdcRoute.Ort2ID = O2.ID
JOIN SdcOrte O3 ON SdcRoute.Ort3ID = O3.ID
JOIN SdcOrte O4 ON SdcRoute.Ort4ID = O4.ID;

GO