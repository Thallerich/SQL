DECLARE @fromdate date = $1$;
DECLARE @todate date = $2$
DECLARE @userid int = (SELECT MitarbeiID FROM #AdvSession);

SELECT [Name], [TA] AS [Träger-An-/Abmeldung], [BV] AS [Bestandsveränderung], [MB] AS [manuelle Bestellung]
FROM (
  SELECT Mitarbei.Name, COUNT(History.ID) AS AnzahlAktion, N'TA' AS Aktion
  FROM History
  JOIN Mitarbei ON History.MitarbeiID = Mitarbei.ID
  WHERE History.HistKatID IN (10013, 10014)  --Träger angelegt, Träger abgemeldet
    AND History.Zeitpunkt BETWEEN @fromdate AND @todate
    AND Mitarbei.ChefMitarbeiID = @userid
  GROUP BY Mitarbei.Name

  UNION ALL

  SELECT Mitarbei.Name, COUNT(VsaAnfHi.ID) AS AnzahlAktion, N'BV' AS Aktion
  FROM VsaAnfHi
  JOIN Mitarbei ON VsaAnfHi.MitarbeiID = Mitarbei.ID
  WHERE VsaAnfHi.Zeitpunkt BETWEEN @fromdate AND @todate
    AND VsaAnfHi.VertragDiff <> 0
    AND Mitarbei.ChefMitarbeiID = @userid
  GROUP BY Mitarbei.Name

  UNION ALL

  SELECT Mitarbei.name, COUNT(AnfKo.ID) AS AnzahlAktion, N'MB' AS Aktion
  FROM AnfKo
  JOIN Mitarbei ON AnfKo.AnlageMitarbeiID = Mitarbei.ID
  WHERE AnfKo.AuftragsDatum BETWEEN @fromdate AND @todate
    AND Mitarbei.ChefMitarbeiID = @userid
  GROUP BY Mitarbei.Name
) AS MAData
PIVOT (
  SUM(AnzahlAktion) FOR Aktion IN ([TA], [BV], [MB])
) AS MAPivot
ORDER BY [Name] ASC;