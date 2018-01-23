DECLARE @von datetime;
DECLARE @bis datetime;

SET @von = $1$;
SET @bis = DATEADD(day, 1, $1$);

SELECT Mitarbeiter, Name, Datum, Anzahl, ROUND(Sekunden/3600, 2) AS Stunden, ROUND(Anzahl/(Sekunden/3600), 2) AS DurchsSetProStunde, ROUND((Sekunden/Anzahl)/60, 2) AS DurchsMinutenProSet
FROM (
  SELECT $1$ AS Datum, Mitarbei.UserName AS Mitarbeiter, Mitarbei.Name, COUNT(OPEtiKo.ID) AS Anzahl,
    CONVERT(float, DATEDIFF(minute, MIN(PackZeitpunkt), MAX(PackZeitpunkt))) AS Minuten,
    IIF(CONVERT(float, DATEDIFF(second, MIN(PackZeitpunkt), MAX(PackZeitpunkt))) = 0, 1, CONVERT(float, DATEDIFF(second, MIN(PackZeitpunkt), MAX(PackZeitpunkt)))) AS Sekunden
  FROM OPEtiKo, Artikel, Mitarbei, Bereich
  WHERE OPEtiKo.PackZeitpunkt BETWEEN @von AND @bis
    AND OPEtiKo.ArtikelID = Artikel.ID
    AND OPEtiKo.PackMitarbeiID = Mitarbei.ID
    AND Artikel.BereichID = Bereich.ID
    AND Bereich.Bereich <> 'RR'
    AND OPEtiKo.ProduktionID IN ($2$)
    AND Mitarbei.UserName <> '120239'
    AND Mitarbei.StandortID IN (-1, 2)
  GROUP BY MItarbei.UserName, Mitarbei.Name
) a

UNION

-- Gesamtsumme aller Mitarbeiter
SELECT 'Z_Gesamt' AS Mitarbeiter, '' AS Name, Datum, SUM(Anzahl) AS Anzahl, SUM(ROUND(Sekunden/3600,2)) AS Stunden, ROUND ((SUM(Anzahl) / SUM(Sekunden/3600)),2) AS DurchsSetProStunde, ROUND ((SUM(Sekunden) / SUM(Anzahl))/60, 2) AS DurchsMinutenProSet
FROM (
  SELECT $1$ AS Datum, Mitarbei.UserName AS Mitarbeiter, Mitarbei.Name, COUNT(OPEtiKo.ID) AS Anzahl,
    CONVERT(float, DATEDIFF(minute, MIN(OPEtiKo.PackZeitpunkt), MAX(OPEtiKo.PackZeitpunkt))) AS Minuten,
    IIF(CONVERT(float, DATEDIFF(second, MIN(PackZeitpunkt), MAX(PackZeitpunkt))) = 0, 1, CONVERT(float, DATEDIFF(second, MIN(PackZeitpunkt), MAX(PackZeitpunkt)))) AS Sekunden
  FROM OPEtiKo, Artikel, Mitarbei, Bereich
  WHERE OPEtiKo.PackZeitpunkt BETWEEN @von AND @bis
    AND OPEtiKo.ArtikelID = Artikel.ID
    AND OPEtiKo.PackMitarbeiID = Mitarbei.ID
    AND Artikel.BereichID = Bereich.ID
    AND Bereich.Bereich <> 'RR'
    AND OPEtiKo.ProduktionID IN ($2$)
    AND Mitarbei.UserName <> '120239'
    AND Mitarbei.StandortID IN (-1, 2)
  GROUP BY Mitarbei.UserName, Mitarbei.Name
) a
GROUP BY Datum;