SELECT CAST(LogItem.Memo AS nchar(100)) AS BKS, FORMAT(LogItem.Anlage_, N'dd.MM.yyyy HH:mm') AS Start, (
  SELECT TOP 1 FORMAT(LogEnde.Anlage_, N'dd.MM.yyyy HH:mm')
  FROM LogItem AS LogEnde
  WHERE LogEnde.LogCaseID = (SELECT LogCase.ID FROM LogCase WHERE LogCase.Bez = N'TMgrRentomat.FullExport')
    AND LogEnde.Bez LIKE N'Ende:%'
    AND CAST(LogEnde.Memo AS nchar(100)) = CAST(LogItem.Memo AS nchar(100))
    AND LogEnde.Anlage_ > LogItem.Anlage_
  ORDER BY LogEnde.Anlage_ ASC
) AS Ende
FROM LogItem
WHERE LogItem.LogCaseID = (SELECT LogCase.ID FROM LogCase WHERE LogCase.Bez = N'TMgrRentomat.FullExport')
  AND LogItem.Bez LIKE N'Start:%'
  AND LogItem.Anlage_ > DATEADD(day, -14, GETDATE())