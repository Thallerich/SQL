DECLARE @fromdate date = $1$;
DECLARE @todate date = $2$;
DECLARE @fromdatetime datetime2 = CAST(@fromdate AS datetime2);
DECLARE @todatetime datetime2 = DATEADD(day, 1, CAST(@todate AS datetime2));
DECLARE @userid int = (SELECT MitarbeiID FROM #AdvSession);

DECLARE @sqltext nvarchar(max);

SET @sqltext = N'
SELECT [Name], [TA] AS [Träger-An-/Abmeldung], [TM] AS [Träger-Aufstockung/Reduzierung], [BV] AS [Bestandsveränderung], [MB] AS [manuelle Bestellung]
FROM (
  SELECT Mitarbei.Name, COUNT(History.ID) AS AnzahlAktion, N''TA'' AS Aktion
  FROM History
  JOIN Mitarbei ON History.MitarbeiID = Mitarbei.ID
  WHERE History.HistKatID IN (10013, 10014)  /* Träger angelegt, Träger abgemeldet */
    AND History.Zeitpunkt BETWEEN @fromdatetime AND @todatetime
    AND (Mitarbei.ChefMitarbeiID = @userid OR Mitarbei.ID = @userid)
  GROUP BY Mitarbei.Name

  UNION ALL

  SELECT Mitarbei.Name, COUNT(History.ID) AS AnzahlAktion, N''TM'' AS Aktion
  FROM History
  JOIN Mitarbei ON History.MitarbeiID = Mitarbei.ID
  WHERE History.HistKatID IN (10046, 10047)  /* Aufstockung, Reduzierung */
    AND History.Zeitpunkt BETWEEN @fromdatetime AND @todatetime
    AND (Mitarbei.ChefMitarbeiID = @userid OR Mitarbei.ID = @userid)
  GROUP BY Mitarbei.Name

  UNION ALL

  SELECT Mitarbei.Name, COUNT(VsaAnfHi.ID) AS AnzahlAktion, N''BV'' AS Aktion
  FROM VsaAnfHi
  JOIN Mitarbei ON VsaAnfHi.MitarbeiID = Mitarbei.ID
  WHERE VsaAnfHi.Zeitpunkt BETWEEN @fromdatetime AND @todatetime
    AND VsaAnfHi.VertragDiff <> 0
    AND (Mitarbei.ChefMitarbeiID = @userid OR Mitarbei.ID = @userid)
  GROUP BY Mitarbei.Name

  UNION ALL

  SELECT Mitarbei.name, COUNT(AnfKo.ID) AS AnzahlAktion, N''MB'' AS Aktion
  FROM AnfKo
  JOIN Mitarbei ON AnfKo.AnlageMitarbeiID = Mitarbei.ID
  WHERE AnfKo.AuftragsDatum BETWEEN @fromdate AND @todate
    AND (Mitarbei.ChefMitarbeiID = @userid OR Mitarbei.ID = @userid)
  GROUP BY Mitarbei.Name
) AS MAData
PIVOT (
  SUM(AnzahlAktion) FOR Aktion IN ([TA], [TM], [BV], [MB])
) AS MAPivot
ORDER BY [Name] ASC;
';

EXEC sp_executesql @sqltext, N'@fromdate date, @fromdatetime datetime2, @todate date, @todatetime datetime2, @userid int', @fromdate, @fromdatetime, @todate, @todatetime, @userid;