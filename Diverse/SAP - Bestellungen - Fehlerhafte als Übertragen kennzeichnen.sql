SET NOCOUNT ON;

DROP TABLE IF EXISTS #PurchaseOrder;
GO

CREATE TABLE #PurchaseOrder (
  OrderNumber bigint
);

GO

DECLARE @RequestXML nvarchar(max);
DECLARE @XMLHandle int;

DECLARE POCursor CURSOR LOCAL FOR
  SELECT SalExLog.HTTPRequest
  FROM SalExLog
  WHERE SalExLog.FunctionName = N'PurchaseOrder'
    AND SalExLog.Anlage_ > N'2022-07-20 07:00:00'
    AND SalExLog.ResponseSuccessful = 0;

OPEN POCursor;

FETCH NEXT FROM POCursor INTO @RequestXML;

WHILE @@FETCH_STATUS = 0
BEGIN
  EXEC sp_xml_preparedocument @XMLHandle OUTPUT, @RequestXML;

  INSERT INTO #PurchaseOrder (OrderNumber)
  SELECT CAST(PurchaseOrderNumber AS bigint)
  FROM OPENXML(@XMLHandle, N'//PurchaseOrderNumber', 1)
  WITH (PurchaseOrderNumber nvarchar(100) N'text()');

  EXEC sp_xml_removedocument @XMLHandle;

  FETCH NEXT FROM POCursor INTO @RequestXML;
END;

CLOSE POCursor;
DEALLOCATE POCursor;

GO

CREATE TABLE __BKOCleanupSAP_20220720 (
  BKoID int PRIMARY KEY CLUSTERED,
  BestNr bigint
);

GO

UPDATE BKo SET SentToSAP = 1
OUTPUT inserted.ID, inserted.BestNr
INTO __BKOCleanupSAP_20220720 (BKoID, BestNr)
WHERE BKo.BestNr IN (
  SELECT OrderNumber
  FROM #PurchaseOrder
);

GO
