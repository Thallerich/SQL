SET NOCOUNT ON;

DECLARE @RequestXML nvarchar(max);
DECLARE @Zeitpunkt datetime;
DECLARE @Success bit;
DECLARE @Response nvarchar(max);
DECLARE @XMLHandle int;
DECLARE @MinLagerBewZeit datetime;

DECLARE @Bestellung TABLE (
  BestellNr bigint PRIMARY KEY
);

CREATE TABLE #StockTransaction (
  TransactionID bigint,
  Zeitpunkt datetime,
  Success bit,
  Response nvarchar(max)
);

INSERT INTO @Bestellung (BestellNr)
VALUES (4500055022), (4500055121), (4500055111), (4500055042), (4500054710), (4500054795), (4500054711), (412003140), (4500055023), (4500055120), (412003312), (4500054079), (4500054428), (4500054613), (4500054797), (412003622), (4500054377);

SELECT @MinLagerBewZeit = MIN(LagerBew.Zeitpunkt)
FROM LagerBew
JOIN LiefLsPo ON LagerBew.LiefLsPoID = LiefLsPo.ID
JOIN BPo ON LiefLsPo.BPoID = BPo.ID
JOIN BKo ON BPo.BKoID = BKo.ID
WHERE BKo.BestNr IN (SELECT BestellNr FROM @Bestellung);

DECLARE SAPStockTransaction CURSOR LOCAL FAST_FORWARD FOR
  SELECT SalExLog.HTTPRequest, SalExLog.Anlage_ AS Zeitpunkt, SalExLog.ResponseSuccessful, SalExLog.ResponseReturnDescriptio
  FROM SalExLog
  WHERE SalExLog.FunctionName = N'StockTransaction'
    AND SalExLog.Anlage_ > @MinLagerBewZeit;

OPEN SAPStockTransaction;

FETCH NEXT FROM SAPStockTransaction INTO @RequestXML, @Zeitpunkt, @Success, @Response;

WHILE @@FETCH_STATUS = 0
BEGIN
  EXEC sp_xml_preparedocument @XMLHandle OUTPUT, @RequestXML;

  INSERT INTO #StockTransaction (TransactionID, Zeitpunkt, Success, Response)
  SELECT CAST(TransactionID AS bigint), @Zeitpunkt, @Success, @Response
  FROM OPENXML(@XMLHandle, N'//TransactionID', 1)
  WITH (TransactionID nvarchar(100) 'text()');

  EXEC sp_xml_removedocument @XMLHandle;

  FETCH NEXT FROM SAPStockTransaction INTO @RequestXML, @Zeitpunkt, @Success, @Response;

END;

CLOSE SAPStockTransaction;
DEALLOCATE SAPStockTransaction;

SELECT BKo.BestNr, Artikel.ArtikelNr, ArtGroe.Groesse AS Größe, LagerBew.ID AS LagerBewID, LagerBew.Zeitpunkt, LagerBew.Differenz AS Bewegung, st.Zeitpunkt AS [SendeZeitpunkt], st.Success, st.Response
FROM LagerBew
JOIN LiefLsPo ON LagerBew.LiefLsPoID = LiefLsPo.ID
JOIN BPo ON LiefLsPo.BPoID = BPo.ID
JOIN BKo ON BPo.BKoID = BKo.ID
JOIN ArtGroe ON BPo.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN #StockTransaction st ON LagerBew.ID = st.TransactionID
WHERE BKo.BestNr IN (SELECT BestellNr FROM @Bestellung);