WITH SapInterface AS (
  SELECT SUBSTRING(SalExLog.HTTPRequest, CHARINDEX(N'<ArticleNumber>', SalExLog.HTTPRequest) + LEN(N'<ArticleNumber>'), CHARINDEX(N'</ArticleNumber>', SalExLog.HTTPRequest) - CHARINDEX(N'<ArticleNumber>', SalExLog.HTTPRequest) - LEN(N'<ArticleNumber>')) AS ArtikelNr,
    SUBSTRING(SalExLog.HTTPRequest, CHARINDEX(N'<Size>', SalExLog.HTTPRequest) + LEN(N'<Size>'), CHARINDEX(N'</Size>', SalExLog.HTTPRequest) - CHARINDEX(N'<Size>', SalExLog.HTTPRequest) - LEN(N'<Size>')) AS Groesse,
    SUBSTRING(SalExLog.HTTPRequest, CHARINDEX(N'<StockLocation>', SalExLog.HTTPRequest) + LEN(N'<StockLocation>'), CHARINDEX(N'</StockLocation>', SalExLog.HTTPRequest) - CHARINDEX(N'<StockLocation>', SalExLog.HTTPRequest) - LEN(N'<StockLocation>')) AS Standort,
    SUBSTRING(SalExLog.HTTPRequest, CHARINDEX(N'<AveragePrice>', SalExLog.HTTPRequest) + LEN(N'<AveragePrice>'), CHARINDEX(N'</AveragePrice>', SalExLog.HTTPRequest) - CHARINDEX(N'<AveragePrice>', SalExLog.HTTPRequest) - LEN(N'<AveragePrice>')) AS AveragePriceSent,
    SalExLog.Anlage_ AS [Zeitpunkt Übertragung SAP]
  FROM SalExLog
  WHERE SalExLog.FunctionName = N'AveragePrice'
    AND SalExLog.ResponseSuccessful = 1
)
SELECT DISTINCT SapInterface.ArtikelNr, SapInterface.Groesse, SapInterface.Standort, CAST(SapInterface.AveragePriceSent AS money) AS AveragePriceSent, SapInterface.[Zeitpunkt Übertragung SAP], ArGrLief.EkPreis
FROM ArGrLief
JOIN ArtiLief ON ArGrLief.ArtiLiefID = ArtiLief.ID
JOIN Standort ON ArtiLief.StandortID = Standort.ID
JOIN ArtGroe ON ArGrLief.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN SapInterface ON Artikel.ArtikelNr = SapInterface.ArtikelNr AND ArtGroe.Groesse = SapInterface.Groesse AND (Standort.SuchCode = SapInterface.Standort OR Standort.ID = -1)
  AND CAST(GETDATE() AS date) BETWEEN ArGrLief.VonDatum AND ISNULL(ArGrLief.BisDatum, N'2099-12-31')
  AND ArtiLief.LiefID != 41971;