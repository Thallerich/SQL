CREATE PROCEDURE _sali_searchsaplog
  @function nvarchar(40) = N'???', /* Possible functions: StockTransaction, Invoice, AveragePrice, PayedWash, PoLineStat, Supplier, Customer, Article, ExchangeRate, PackingNote, PurchaseOrder, AveragePrice_verbose */
  @searchstring nvarchar(40) = NULL,
  @datetimefilter datetime2 = NULL
AS

  SET NOCOUNT ON;

  DECLARE @errorflag tinyint = 0;
  DECLARE @xmlfiltertext nvarchar(300);
  DECLARE @sqltext nvarchar(max);

  IF @datetimefilter IS NULL
    SET @datetimefilter = DATEADD(day, -7, DATETIME2FROMPARTS(DATEPART(year, GETDATE()), DATEPART(month, GETDATE()), DATEPART(day, GETDATE()), 0, 0, 0, 0, 0)); /* look at the last 7 days */

  IF @searchstring IS NULL
    SET @errorflag = 1;
  ELSE
  BEGIN
    SET @xmlfiltertext = 
      CASE @function
        WHEN N'Article'
          THEN N'SUBSTRING(SalExLog.HTTPRequest, CHARINDEX(N''<ArticleNumber>'', SalExLog.HTTPRequest, 1) + 15, CHARINDEX(N''</ArticleNumber>'', SalExLog.HTTPRequest, 1) - (CHARINDEX(N''<ArticleNumber>'', SalExLog.HTTPRequest, 1) + 15)) = @searchstring'
        WHEN N'Invoice'
          THEN N'SUBSTRING(SalExLog.HTTPRequest, CHARINDEX(N''<InvoiceNumber>'', SalExLog.HTTPRequest, 1) + 15, CHARINDEX(N''</InvoiceNumber>'', SalExLog.HTTPRequest, 1) - (CHARINDEX(N''<InvoiceNumber>'', SalExLog.HTTPRequest, 1) + 15)) = @searchstring'
        WHEN N'Customer'
          THEN N'TRY_CAST(SUBSTRING(SalExLog.HTTPRequest, CHARINDEX(N''<Number>'', SalExLog.HTTPRequest, 1) + 8, CHARINDEX(N''</Number>'', SalExLog.HTTPRequest, 1) - (CHARINDEX(N''<Number>'', SalExLog.HTTPRequest, 1) + 8)) AS int) = TRY_CAST(@searchstring AS int)'
        WHEN N'PayedWash'
          THEN N'TRY_CAST(SUBSTRING(SalExLog.HTTPRequest, CHARINDEX(N''<DeliveryNoteNumber>'', SalExLog.HTTPRequest, 1) + 20, CHARINDEX(N''</DeliveryNoteNumber>'', SalExLog.HTTPRequest, 1) - (CHARINDEX(N''<DeliveryNoteNumber>'', SalExLog.HTTPRequest, 1) + 20)) AS int) = TRY_CAST(@searchstring AS int)'
        WHEN N'StockTransaction'
          THEN N'TRY_CAST(SUBSTRING(SalExLog.HTTPRequest, CHARINDEX(N''<TransactionID>'', SalExLog.HTTPRequest, 1) + 15, CHARINDEX(N''</TransactionID>'', SalExLog.HTTPRequest, 1) - (CHARINDEX(N''<TransactionID>'', SalExLog.HTTPRequest, 1) + 15)) AS int) = TRY_CAST(@searchstring AS int)'
        WHEN N'PackingNote_WO'
          THEN N'TRY_CAST(SUBSTRING(SalExLog.HTTPRequest, CHARINDEX(N''<WorkOrderNumber>'', SalExLog.HTTPRequest, 1) + 17, CHARINDEX(N''</WorkOrderNumber>'', SalExLog.HTTPRequest, 1) - (CHARINDEX(N''<WorkOrderNumber>'', SalExLog.HTTPRequest, 1) + 17)) AS int) = TRY_CAST(@searchstring AS int)'
        WHEN N'PackingNote_DN'
          THEN N'TRY_CAST(SUBSTRING(SalExLog.HTTPRequest, CHARINDEX(N''<DeliveryNoteNumber>'', SalExLog.HTTPRequest, 1) + 20, CHARINDEX(N''</DeliveryNoteNumber>'', SalExLog.HTTPRequest, 1) - (CHARINDEX(N''<DeliveryNoteNumber>'', SalExLog.HTTPRequest, 1) + 20)) AS int) = TRY_CAST(@searchstring AS int)'
        WHEN N'PurchaseOrder'
          THEN N'TRY_CAST(SUBSTRING(SalExLog.HTTPRequest, CHARINDEX(N''<PurchaseOrderNumber>'', SalExLog.HTTPRequest, 1) + 21, CHARINDEX(N''</PurchaseOrderNumber>'', SalExLog.HTTPRequest, 1) - (CHARINDEX(N''<PurchaseOrderNumber>'', SalExLog.HTTPRequest, 1) + 21)) AS int) = TRY_CAST(@searchstring AS int)'
        WHEN N'Supplier'
          THEN N'TRY_CAST(SUBSTRING(SalExLog.HTTPRequest, CHARINDEX(N''<Number>'', SalExLog.HTTPRequest, 1) + 8, CHARINDEX(N''</Number>'', SalExLog.HTTPRequest, 1) - (CHARINDEX(N''<Number>'', SalExLog.HTTPRequest, 1) + 8)) AS int) = TRY_CAST(@searchstring AS int)'
        ELSE NULL
    END;

    IF @xmlfiltertext IS NULL
      SET @errorflag += 2;
  END;
  
  IF @errorflag = 0
    BEGIN
      SET @sqltext = N'
      SELECT SalExLog.Anlage_ AS Zeitpunkt, SalExLog.HTTPRequest, SalExLog.ResponseSuccessful AS [Success?], SalExLog.ResponseReturnDescriptio AS [SAP-Response]
      FROM SalExLog
      WHERE SalExLog.Anlage_ > @filter
        AND SalExLog.FunctionName = @function
        AND ' + @xmlfiltertext + '
      ORDER BY Zeitpunkt DESC;
      ';

      EXEC sp_executesql @sqltext, N'@filter datetime2, @function nvarchar(40), @searchstring nvarchar(40)', @datetimefilter, @function, @searchstring;
    END;
  
  IF @errorflag = 1
    SELECT N'FEHLER: Kein Suchtext angegeben!'
    UNION
    SELECT N'Aufruf: EXEC _sali_searchsaplog @functionname = N''<<funktion>>'', @searchstring = N''<<suchtext>>''';
  IF @errorflag = 2
    SELECT N'FEHLER: Keine gültige Funktion angegeben!'
    UNION
    SELECT N'Aufruf: EXEC _sali_searchsaplog @functionname = N''<<funktion>>'', @searchstring = N''<<suchtext>>''';
  IF @errorflag = 3
    SELECT N'FEHLER: Keine gültige Funktion angegeben!'
    UNION
    SELECT N'FEHLER: Kein Suchtext angegeben!'
    UNION
    SELECT N'Aufruf: EXEC _sali_searchsaplog @functionname = N''<<funktion>>'', @searchstring = N''<<suchtext>>''';