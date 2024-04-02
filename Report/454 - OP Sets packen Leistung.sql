/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline (vorbereitend): prepareData                                                                                      ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #Result454;

CREATE TABLE #Result454 (
  Datum date,
  Mitarbeiter varchar(8),
  [Name] nvarchar(120),
  Anzahl int,
  Minuten float,
  Sekunden float
);

DECLARE @von datetime = $1$;
DECLARE @bis datetime = DATEADD(day, 1, $1$);
DECLARE @produktion advintegerlist;
DECLARE @sqltext nvarchar(max);

INSERT INTO @produktion
SELECT [value]
FROM STRING_SPLIT('$2$', ',')

SET @sqltext = N'
DECLARE @OPEtiKo454 TABLE (
  OPEtiKoID int PRIMARY KEY CLUSTERED
);

INSERT INTO @OPEtiKo454 (OPEtiKoID)
SELECT OPEtiKo.ID
FROM OPEtiKo
WHERE OPEtiKo.PackZeitpunkt BETWEEN @von AND @bis;

SELECT CAST(@von AS date) AS Datum,
  Mitarbei.UserName AS Mitarbeiter,
  Mitarbei.Name,
  COUNT(OPEtiKo.ID) AS Anzahl,
  CONVERT(float, DATEDIFF(minute, MIN(PackZeitpunkt), MAX(PackZeitpunkt))) AS Minuten,
  IIF(CONVERT(float, DATEDIFF(second, MIN(PackZeitpunkt), MAX(PackZeitpunkt))) = 0, 1, CONVERT(float, DATEDIFF(second, MIN(PackZeitpunkt), MAX(PackZeitpunkt)))) AS Sekunden
FROM @OPEtiKo454
JOIN OPEtiKo ON [@OPEtiKo454].OPEtiKoID = OPEtiKo.ID
JOIN Mitarbei ON OPEtiKo.PackMitarbeiID = Mitarbei.ID
WHERE OPEtiKo.ArtikelID NOT IN (SELECT Artikel.ID FROM Artikel WHERE Artikel.BereichID = (SELECT Bereich.ID FROM Bereich WHERE Bereich = N''RR''))
  AND OPEtiKo.ProduktionID IN (SELECT i FROM @produktion)
  AND Mitarbei.UserName <> ''120239''
GROUP BY MItarbei.UserName, Mitarbei.Name;
';

INSERT INTO #Result454 (Datum, Mitarbeiter, [Name], Anzahl, Minuten, Sekunden)
EXEC sp_executesql @sqltext, N'@von datetime, @bis datetime, @produktion advintegerlist READONLY', @von, @bis, @produktion;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipline (Haupt): OPSets                                                                                                   ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Mitarbeiter, Name, Datum, Anzahl, ROUND(Sekunden/3600, 2) AS Stunden, ROUND(Anzahl/(Sekunden/3600), 2) AS DurchsSetProStunde, ROUND((Sekunden/Anzahl)/60, 2) AS DurchsMinutenProSet
FROM #Result454

UNION

-- Gesamtsumme aller Mitarbeiter
SELECT 'ZZZ_Gesamt' AS Mitarbeiter, '' AS Name, Datum, SUM(Anzahl) AS Anzahl, SUM(ROUND(Sekunden/3600,2)) AS Stunden, ROUND ((SUM(Anzahl) / SUM(Sekunden/3600)),2) AS DurchsSetProStunde, ROUND ((SUM(Sekunden) / SUM(Anzahl))/60, 2) AS DurchsMinutenProSet
FROM #Result454
GROUP BY Datum;