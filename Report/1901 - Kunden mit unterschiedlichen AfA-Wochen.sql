DROP TABLE IF EXISTS #TmpMultiAfa;

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, KdArti.AfaWochen, COUNT(KdArti.ID) AS KdArtiAnz
INTO #TmpMultiAfa
FROM KdArti
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE Kunden.FirmaID = $1$
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
  AND Kunden.Status = N'A'
  AND KdArti.Status = N'A'
  AND Artikel.ArtiTypeID = 1 /* Textiler Artikel */
  AND EXISTS (
    SELECT KdArti.KundenID
    FROM KdArti
    JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
    WHERE KdArti.KundenID = Kunden.ID
      AND KdArti.Status = N'A'
      AND Artikel.ArtiTypeID = 1 /* Textiler Artikel */
      AND EXISTS (
        SELECT TraeArti.*
        FROM TraeArti
        JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
        WHERE TraeArti.KdArtiID = KdArti.ID
          AND Traeger.Altenheim = 0
      )
    GROUP BY KdArti.KundenID
    HAVING COUNT(DISTINCT KdArti.AfaWochen) > 1
  )
  AND EXISTS (
    SELECT TraeArti.*
    FROM TraeArti
    JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
    WHERE TraeArti.KdArtiID = KdArti.ID
      AND Traeger.Altenheim = 0
  )
GROUP BY Kunden.KdNr, Kunden.SuchCode, KdArti.AfaWochen;

DECLARE @pivotcols nvarchar(max);
DECLARE @pivotcolshead nvarchar(max);
DECLARE @pivotsql nvarchar(max);

IF NOT EXISTS (SELECT * FROM #TmpMultiAfa)
BEGIN
  SET @pivotsql = N'SELECT N''Keine Abweichungen gefunden!'' AS Meldung;';
END
ELSE
BEGIN
  SET @pivotcols = STUFF((SELECT ', [' + CAST(AfaWochen AS nvarchar) + ']' FROM #TmpMultiAfa GROUP BY AfaWochen ORDER BY AfaWochen FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,1,'');
  SET @pivotcolshead = STUFF((SELECT ', [' + CAST(AfaWochen AS nvarchar) + '] AS [AfaWochen ' + CAST(AfaWochen AS nvarchar) + N']' FROM #TmpMultiAfa GROUP BY AfaWochen ORDER BY AfaWochen FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,1,'');
  SET @pivotsql = N'SELECT KdNr, Kunde, ' + @pivotcolshead + N' FROM #TmpMultiAfa AS PivotData PIVOT (SUM(KdArtiAnz) FOR AfaWochen IN (' + @pivotcols + N')) AS p ORDER BY KdNr ASC;';
END;

EXEC sp_executesql @pivotsql;