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

SELECT Standort.SuchCode AS Standort,
  [Geräte-Art] = 
    CASE MdeDev.Art
      WHEN N'H' THEN N'Fahrer-App'
      WHEN N'O' THEN N'Pool-Inventur'
      ELSE N'(Unknown)'
    END,
  COUNT(DISTINCT Mitarbei.ID) AS [Anzahl User]
FROM MdeDev
JOIN Mitarbei ON MdeDev.LastMitarbeiID = Mitarbei.ID
JOIN Standort ON Mitarbei.StandortID = Standort.ID
WHERE MdeDev.LastMitarbeiID > 0
  AND MdeDev.LetzterZugriff >= N'2021-07-01 00:00:00'
  AND MdeDev.Status = N'A'
GROUP BY Standort.SuchCode,
  CASE MdeDev.Art
    WHEN N'H' THEN N'Fahrer-App'
    WHEN N'O' THEN N'Pool-Inventur'
    ELSE N'(Unknown)'
  END;

GO