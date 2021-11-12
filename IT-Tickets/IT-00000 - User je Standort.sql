WITH PCList AS (
  SELECT PCName, [Location]
  FROM __PCList

  UNION

  SELECT PCName, IIF(CHARINDEX(N'_', [Location], 1) = 0, [Location], LEFT([Location], CHARINDEX(N'_', [Location], 1) - 1))
  FROM __TCList
)
SELECT PCList.[Location], COUNT(DISTINCT Mitarbei.ID) AS [Anzahl User], COUNT(DISTINCT ArbPlatz.ID) AS [Anzahl Arbeitsplätze]
FROM LoginLog
JOIN Mitarbei ON LoginLog.UserID = Mitarbei.ID
JOIN ArbPlatz ON LoginLog.ArbPlatzID = ArbPlatz.ID
JOIN PCList ON UPPER(ArbPlatz.ComputerName) = UPPER(PCList.PCName) COLLATE Latin1_General_CS_AS
WHERE LoginLog.LoginZeit >= N'2021-07-01'
GROUP BY PCList.[Location];

GO