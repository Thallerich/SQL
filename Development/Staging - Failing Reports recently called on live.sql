USE Salesianer;
GO

SELECT ChartKo.RepNr, ChartKo.ChartKoBez, __ChartLastCall.LastCall
FROM ChartKo
JOIN __ChartLastCall ON __ChartLastCall.RepNr COLLATE Latin1_General_CS_AS = ChartKo.RepNr
WHERE ChartKo.Fehlerhaft = 1
  AND __ChartLastCall.LastCall > DATEADD(day, -14, GETDATE())
ORDER BY LastCall DESC;

GO