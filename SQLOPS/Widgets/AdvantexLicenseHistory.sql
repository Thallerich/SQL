SELECT LoginUse.Datum, LoginUse.AnzSessions
FROM LoginUse
WHERE LoginUse.Datum BETWEEN CAST(DATEADD(day, -30, GETDATE()) AS date) AND CAST(DATEADD(day, -1, GETDATE()) AS date)
  AND DATEPART(weekday, LoginUse.Datum) NOT IN (7, 1) -- Samstag / Sonntag
ORDER BY Datum ASC;