DECLARE @rechnr int = 70034557;

DECLARE @datefilter datetime2 = DATEADD(month, -2, DATETIME2FROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1, 0, 0, 0, 0, 0));
DECLARE @sqltext nvarchar(max) = N'
  SELECT SalExLog.Anlage_ AS Zeitpunkt, SalExLog.FunctionName, SalExLog.HTTPRequest, SalExLog.ResponseReturnDescriptio AS Response, SalExLog.ResponseSuccessful
  FROM SalExLog
  WHERE SalExLog.FunctionName = N''Invoice''
    AND SalExLog.Anlage_ >= @datefilter
    AND SalExLog.HTTPRequest LIKE N''%<InvoiceNumber>'' + CAST(@rechnr AS nvarchar) + N''</InvoiceNumber>%''
  ORDER BY Zeitpunkt DESC;
';

EXEC sp_executesql @sqltext, N'@rechnr int, @datefilter datetime2', @rechnr, @datefilter;

GO