DECLARE @previousday datetime2 = DATEADD(day, -1, CAST(GETDATE() AS date));
DECLARE @daystart datetime2 = DATEFROMPARTS(YEAR(@previousday), MONTH(@previousday), DAY(@previousday));
DECLARE @dayend datetime2 = DATEADD(day, 1, DATEFROMPARTS(YEAR(@previousday), MONTH(@previousday), DAY(@previousday)));
DECLARE @sqltext nvarchar(max);

SET @sqltext = N'SELECT EinzHist.Barcode, EinzHist.RentomatChip, Scans.[DateTime] AS Entnahmezeitpunkt, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse, ISNULL(Traeger.Nachname, N'''') + N'' '' + ISNULL(Traeger.Vorname, N'''') + N'' ('' + Traeger.Traeger + N'')'' AS [entnommen von]
FROM Scans
JOIN EinzHist ON Scans.EinzHistID = EinzHist.ID
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Traeger ON Scans.LastPoolTraegerID = Traeger.ID
WHERE Vsa.ID = 6140348
  AND Scans.[DateTime] BETWEEN @daystart AND @dayend
  AND Scans.ActionsID = 65;'

EXEC sp_executesql @sqltext, N'@daystart datetime2, @dayend datetime2', @daystart, @dayend;