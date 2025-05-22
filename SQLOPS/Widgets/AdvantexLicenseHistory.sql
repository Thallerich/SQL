SELECT LoginUse.Datum, LoginUse.AnzSessions
FROM LoginUse
WHERE LoginUse.Datum BETWEEN CAST(DATEADD(day, -30, GETDATE()) AS date) AND CAST(GETDATE() AS date)
  AND LoginUse.Type = 0
  /* AND DATEPART(weekday, LoginUse.Datum) NOT IN (7, 1) -- Samstag / Sonntag */
ORDER BY Datum ASC;