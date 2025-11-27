SELECT EinzTeil.Code, Teilestatus.StatusBez AS [Status des Teils], Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Standort.Bez AS Produktion, ZielNr.ZielNrBez AS [letzter Scan-Ort], Actions.ActionsBez AS [letzte Aktion], EinzTeil.LastScanTime AS [Zeitpunkt letzter Scan], EinzTeil.LastScanToKunde AS [Zeitpunkt letzter Ausgangs-Scan], DATEDIFF(day, EinzTeil.LastScanTime, GETDATE()) AS [nicht mehr gescannt seit (Tagen)]
FROM EinzTeil
JOIN Actions ON EinzTeil.LastActionsID = Actions.ID
JOIN ZielNr ON EinzTeil.ZielNrID = ZielNr.ID
JOIN Standort ON ZielNr.ProduktionsID = Standort.ID
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
JOIN (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZTEIL'
) AS Teilestatus ON EinzTeil.Status = Teilestatus.Status
WHERE EinzTeil.Status < 'W'
  AND LEN(EinzTeil.Code) = 24
  AND Standort.SuchCode LIKE N'WOE_'
  AND EinzTeil.LastScanTime > N'2025-07-01 00:00:00.000'
  AND EinzTeil.LastScanTime < N'2025-11-01 00:00:00.000'
  AND EinzTeil.LastActionsID NOT IN (2, 102, 120, 129, 130, 136, 137, 154, 165, 173);

GO

SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Standort.Bez AS Produktion, FORMAT(EinzTeil.LastScanTime, 'yyyy-MM-dd') AS [Datum letzter Scan], COUNT(EinzTeil.Code) AS [Anzahl der Teile]
FROM EinzTeil
JOIN Actions ON EinzTeil.LastActionsID = Actions.ID
JOIN ZielNr ON EinzTeil.ZielNrID = ZielNr.ID
JOIN Standort ON ZielNr.ProduktionsID = Standort.ID
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
JOIN (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZTEIL'
) AS Teilestatus ON EinzTeil.Status = Teilestatus.Status
WHERE EinzTeil.Status < 'W'
  AND LEN(EinzTeil.Code) = 24
  AND Standort.SuchCode LIKE N'WOE_'
  AND EinzTeil.LastScanTime > N'2025-07-01 00:00:00.000'
  AND EinzTeil.LastScanTime < N'2025-11-01 00:00:00.000'
  AND EinzTeil.LastActionsID NOT IN (2, 102, 120, 129, 130, 136, 137, 154, 165, 173)
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez, Standort.Bez, FORMAT(EinzTeil.LastScanTime, 'yyyy-MM-dd')
HAVING COUNT(EinzTeil.Code) > 100
ORDER BY Produktion, [Anzahl der Teile] DESC;

GO