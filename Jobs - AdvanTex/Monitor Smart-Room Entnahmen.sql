DECLARE @daystart datetime2 = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), DAY(GETDATE()));
DECLARE @dayend datetime2 = DATEADD(day, 1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), DAY(GETDATE())));
DECLARE @sqltext nvarchar(max);

SET @sqltext = N'SELECT Teile.Barcode, Teile.RentomatChip, Scans.[DateTime] AS Entnahmezeitpunkt, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse, ISNULL(Traeger.Nachname, N'''') + N'' '' + ISNULL(Traeger.Vorname, N'''') + N'' ('' + Traeger.Traeger + N'')'' AS [entnommen von]
FROM Scans
JOIN Teile ON Scans.TeileID = Teile.ID
JOIN Vsa ON Teile.VsaID = Vsa.ID
JOIN ArtGroe ON Teile.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Traeger ON Scans.LastPoolTraegerID = Traeger.ID
WHERE Vsa.ID = 6140348
  AND Scans.[DateTime] BETWEEN @daystart AND @dayend
  AND Scans.ActionsID = 65;'

EXEC sp_executesql @sqltext, N'@daystart datetime2, @dayend datetime2', @daystart, @dayend;