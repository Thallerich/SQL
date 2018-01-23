/* Anzahl der Leerlieferscheine (f�r zwingende Anfahrt) pro Tag*/

SELECT LsKo.Datum, COUNT(LsKo.ID) AS Leer
FROM LsKo
LEFT OUTER JOIN LsPo ON LsPo.LsKoID = LsKo.ID
WHERE LsPo.LsKoID IS NULL
GROUP BY LsKo.Datum
ORDER BY LsKo.Datum DESC