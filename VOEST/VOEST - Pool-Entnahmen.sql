DROP TABLE IF EXISTS #ScanEntnahme, #ScanRueckgabe, #Verkaufsteile, #PoolStatistik;
GO

DECLARE @von datetime2 = N'2024-01-01 00:00:00.000', @bis datetime2 = N'2025-01-01 00:00:00.000';

SELECT Scans.EinzHistID, Scans.[DateTime] AS Entnahme, Scans.TraegerID, EinzHist.KdArtiID, EinzHist.ArtGroeID
INTO #ScanEntnahme
FROM Scans
JOIN EinzHist ON Scans.EinzHistID = EinzHist.ID
JOIN Traeger ON Scans.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.KdNr = 272295
  AND Vsa.VsaNr IN (902, 903)
  AND Scans.ActionsID = 2
  AND Scans.[DateTime] >= @von
  AND Scans.[DateTime] < @bis
  AND Scans.LsPoID > 0
  AND Traeger.ParentTraegerID > 0;

SELECT Scans.EinzHistID, CAST(NULL AS datetime2) AS Rückgabe, Scans.TraegerID, EinzHist.KdArtiID, EinzHist.ArtGroeID, NextScanID = (
    SELECT MIN(s.ID)
    FROM Scans s
    WHERE s.EinzHistID = Scans.EinzHistID
      AND s.ID > Scans.ID
      AND (s.Menge = 1 OR s.ActionsID = 159 OR s.ActionsID = 162)
      AND s.[DateTime] < @bis
  )
INTO #ScanRueckgabe
FROM Scans
JOIN EinzHist ON Scans.EinzHistID = EinzHist.ID
JOIN Traeger ON Scans.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.KdNr = 272295
  AND Vsa.VsaNr IN (902, 903)
  AND Scans.ActionsID = 2
  AND Scans.[DateTime] >= @von
  AND Scans.[DateTime] < @bis
  AND Scans.LsPoID > 0
  AND Traeger.ParentTraegerID > 0;

DELETE FROM #ScanRueckgabe WHERE NextScanID IS NULL;

UPDATE #ScanRueckgabe SET Rückgabe = Scans.[DateTime]
FROM Scans
WHERE Scans.ID = #ScanRueckgabe.NextScanID;

SELECT Scans.EinzHistID, Scans.DateTime AS Scanzeitpunkt, CAST(NULL AS datetime2) AS Zeitpunkt, CAST(0 AS bit) AS Gutgeschrieben, Scans.TraegerID, EinzHist.KdArtiID, EinzHist.ArtGroeID
INTO #Verkaufsteile
FROM Scans
JOIN EinzHist ON Scans.EinzHistID = EinzHist.ID
JOIN Traeger ON Scans.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.KdNr = 272295
  AND Vsa.VsaNr IN (902, 903)
  AND Scans.ActionsID = 162
  AND Scans.[DateTime] >= @von
  AND Scans.[DateTime] < @bis;

UPDATE #Verkaufsteile SET Zeitpunkt = TeilSoFa.Zeitpunkt, Gutgeschrieben = IIF(TeilSofa.Status >= N'T', 1, 0)
FROM #Verkaufsteile
JOIN TeilSoFa ON TeilSoFa.EinzHistID = #Verkaufsteile.EinzHistID AND TeilSoFa.Zeitpunkt >= DATEADD(minute, -1, #Verkaufsteile.Scanzeitpunkt) AND TeilSoFa.Zeitpunkt <= DATEADD(minute, 1, #Verkaufsteile.Scanzeitpunkt);

SELECT #ScanEntnahme.TraegerID, #ScanEntnahme.KdArtiID, #ScanEntnahme.ArtGroeID, FORMAT(#ScanEntnahme.Entnahme, N'yyyy-MM') + N'_1' AS Monat, COUNT(*) AS Menge
INTO #PoolStatistik
FROM #ScanEntnahme
GROUP BY #ScanEntnahme.TraegerID, #ScanEntnahme.KdArtiID, #ScanEntnahme.ArtGroeID, FORMAT(#ScanEntnahme.Entnahme, N'yyyy-MM') + N'_1';

INSERT INTO #PoolStatistik (TraegerID, KdArtiID, ArtGroeID, Monat, Menge)
SELECT #ScanRueckgabe.TraegerID, #ScanRueckgabe.KdArtiID, #ScanRueckgabe.ArtGroeID, FORMAT(#ScanRueckgabe.Rückgabe, N'yyyy-MM') + N'_2' AS Monat, COUNT(*) AS Menge
FROM #ScanRueckgabe
GROUP BY #ScanRueckgabe.TraegerID, #ScanRueckgabe.KdArtiID, #ScanRueckgabe.ArtGroeID, FORMAT(#ScanRueckgabe.Rückgabe, N'yyyy-MM') + N'_2';

INSERT INTO #PoolStatistik (TraegerID, KdArtiID, ArtGroeID, Monat, Menge)
SELECT #Verkaufsteile.TraegerID, #Verkaufsteile.KdArtiID, #Verkaufsteile.ArtGroeID, FORMAT(#Verkaufsteile.Zeitpunkt, N'yyyy-MM') + N'_3' AS Monat, COUNT(*) AS Menge
FROM #Verkaufsteile
GROUP BY #Verkaufsteile.TraegerID, #Verkaufsteile.KdArtiID, #Verkaufsteile.ArtGroeID, FORMAT(#Verkaufsteile.Zeitpunkt, N'yyyy-MM') + N'_3';

INSERT INTO #PoolStatistik (TraegerID, KdArtiID, ArtGroeID, Monat, Menge)
SELECT #Verkaufsteile.TraegerID, #Verkaufsteile.KdArtiID, #Verkaufsteile.ArtGroeID, FORMAT(#Verkaufsteile.Zeitpunkt, N'yyyy-MM') + N'_4' AS Monat, COUNT(*) AS Menge
FROM #Verkaufsteile
WHERE #Verkaufsteile.Gutgeschrieben = 1
GROUP BY #Verkaufsteile.TraegerID, #Verkaufsteile.KdArtiID, #Verkaufsteile.ArtGroeID, FORMAT(#Verkaufsteile.Zeitpunkt, N'yyyy-MM') + N'_4';

IF (SELECT TOP 1 TraegerID FROM #PoolStatistik) IS NOT NULL
BEGIN
  DECLARE @pivotcols nvarchar(max), @pivotcolshead nvarchar(max), @pivotsql nvarchar(max);

  SET @pivotcols = STUFF((SELECT DISTINCT N', [' + Monat + N']' FROM #PoolStatistik ORDER BY 1 FOR XML PATH(N''), TYPE).value(N'.', N'NVARCHAR(MAX)'), 1, 1, N'');
  SET @pivotcolshead = STUFF((SELECT DISTINCT N', [' + Monat + N'] AS [' + CASE RIGHT(Monat, 1) WHEN N'1' THEN N'Entnahme ' WHEN N'2' THEN N'Rückgabe ' WHEN N'3' THEN N'Verkauf ' WHEN N'4' THEN N'Gutschrift ' END + LEFT(Monat, 7) + N']' FROM #PoolStatistik ORDER BY 1 FOR XML PATH(N''), TYPE).value(N'.', N'NVARCHAR(MAX)'), 1, 1, N'');

  SET @pivotsql = N'
    SELECT KdNr, Kunde, VsaNr, [Vsa-Bezeichnung], Abteilung, Kostenstelle, Kostenstellenbezeichnung, Traeger, PersNr, Vorname, Nachname, ArtikelNr, Artikelbezeichnung, Größe, Variante, ' + @pivotcolshead + N'
    FROM (
      SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], VaterVsa.GebaeudeBez AS Abteilung, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Traeger.Traeger, Traeger.PersNr, Traeger.Vorname, Traeger.Nachname, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, KdArti.Variante, PoolStatistik.Monat, PoolStatistik.Menge
      FROM #PoolStatistik AS PoolStatistik
      JOIN Traeger ON PoolStatistik.TraegerID = Traeger.ID
      JOIN Vsa ON Traeger.VsaID = Vsa.ID
      JOIN Kunden ON Vsa.KundenID = Kunden.ID
      JOIN Traeger AS VaterTraeger ON Traeger.ParentTraegerID = VaterTraeger.ID
      JOIN Vsa AS VaterVsa ON VaterTraeger.VsaID = VaterVsa.ID
      JOIN KdArti ON PoolStatistik.KdArtiID = KdArti.ID
      JOIN ArtGroe ON PoolStatistik.ArtGroeID = ArtGroe.ID
      JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
      JOIN Abteil ON Traeger.AbteilID = Abteil.ID
    ) AS PivotData
    PIVOT (SUM(Menge) FOR Monat IN (' + @pivotcols + N')) AS b;
  ';
  
  EXEC sp_executesql @pivotsql;
END
ELSE
  SELECT N'Keine Daten verfügbar!' AS Fehler;

GO