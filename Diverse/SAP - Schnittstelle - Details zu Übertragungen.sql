USE Salesianer;
GO

SELECT SalExLog.Anlage_ AS [Timestamp],
  KdNr = SUBSTRING(SalExLog.HTTPRequest, CHARINDEX(N'<Number>', SalExLog.HTTPRequest, 1) + 8, CHARINDEX(N'</Number>', SalExLog.HTTPRequest, 1) - (CHARINDEX(N'<Number>', SalExLog.HTTPRequest, 1) + 8)),
  Debitor = SUBSTRING(SalExLog.HTTPRequest, CHARINDEX(N'<Debtor>', SalExLog.HTTPRequest, 1) + 8, CHARINDEX(N'</Debtor>', SalExLog.HTTPRequest, 1) - (CHARINDEX(N'<Debtor>', SalExLog.HTTPRequest, 1) + 8)),
  SuchCode = SUBSTRING(SalExLog.HTTPRequest, CHARINDEX(N'<SearchName>', SalExLog.HTTPRequest, 1) + 12, CHARINDEX(N'</SearchName>', SalExLog.HTTPRequest, 1) - (CHARINDEX(N'<SearchName>', SalExLog.HTTPRequest, 1) + 12)),
  Fehlermeldung = SalExLog.ResponseReturnDescriptio
FROM SalExLog
WHERE SalExLog.FunctionName = N'Customer'
  AND SalExLog.Anlage_ > N'2023-10-03 00:00:00'
ORDER BY [Timestamp] ASC;

GO

SELECT SalExLog.Anlage_ AS [Timestamp],
  LiefNr = SUBSTRING(SalExLog.HTTPRequest, CHARINDEX(N'<Number>', SalExLog.HTTPRequest, 1) + 8, CHARINDEX(N'</Number>', SalExLog.HTTPRequest, 1) - (CHARINDEX(N'<Number>', SalExLog.HTTPRequest, 1) + 8)),
  [Name] = SUBSTRING(SalExLog.HTTPRequest, CHARINDEX(N'<Name>', SalExLog.HTTPRequest, 1) + 6, CHARINDEX(N'</Name>', SalExLog.HTTPRequest, 1) - (CHARINDEX(N'<Name>', SalExLog.HTTPRequest, 1) + 6)),
  Fehlermeldung = SalExLog.ResponseReturnDescriptio
FROM SalExLog
WHERE SalExLog.FunctionName = N'Supplier'
  AND SalExLog.Anlage_ > N'2023-10-03 00:00:00'
ORDER BY [Timestamp] ASC;

GO