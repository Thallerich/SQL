USE Wozabal
GO

SELECT RTRIM(SetArtikel.ArtikelNr) AS [Set-Artikelnummer], 
  RTRIM(SetArtikel.ArtikelBez) AS [Set-Artikelbezeichnung],
  OPSets.Position, 
  RTRIM(InhaltsArtikel1.ArtikelNr) AS [Inhalts-Artikelnummer 1], 
  RTRIM(InhaltsArtikel1.ArtikelBez) AS [Inhalts-Artikelbezeichnung 1], 
  IIF(InhaltsArtikel2.ID < 0, N'', RTRIM(InhaltsArtikel2.ArtikelNr)) AS [Inhalts-Artikelnummer 2], 
  ISNULL(RTRIM(InhaltsArtikel2.ArtikelBez), N'') AS [Inhalts-Artikelbezeichnung 2], 
  IIF(InhaltsArtikel3.ID < 0, N'', RTRIM(InhaltsArtikel3.ArtikelNr)) AS [Inhalts-Artikelnummer 3],
  ISNULL(RTRIM(InhaltsArtikel3.ArtikelBez), N'') AS [Inhalts-Artikelbezeichnung 3], 
  IIF(InhaltsArtikel4.ID < 0, N'', RTRIM(InhaltsArtikel4.ArtikelNr)) AS [Inhalts-Artikelnummer 4], 
  ISNULL(RTRIM(InhaltsArtikel4.ArtikelBez), N'') AS [Inhalts-Artikelbezeichnung 4],
  CASE OPSets.Modus
    WHEN 0 THEN N'Position wird beim Packen grunsätzlich nicht angezeigt'
    WHEN 1 THEN N'Position verschwindet mit der Folgeposition automatisch'
  END AS Modus
FROM OPSets
JOIN Artikel AS SetArtikel ON OPSets.ArtikelID = SetArtikel.ID
JOIN Bereich ON SetArtikel.BereichID = Bereich.ID
JOIN Artikel AS InhaltsArtikel1 ON OPSets.Artikel1ID = InhaltsArtikel1.ID
JOIN Artikel AS InhaltsArtikel2 ON OPSets.Artikel2ID = InhaltsArtikel2.ID
JOIN Artikel AS InhaltsArtikel3 ON OPSets.Artikel3ID = InhaltsArtikel3.ID
JOIN Artikel AS InhaltsArtikel4 ON OPSets.Artikel4ID = InhaltsArtikel4.ID
WHERE OPSets.Modus IN (0, 1)
AND OPSets.ID > 0
AND Bereich.Bereich = N'OP'
AND InhaltsArtikel1.ArtikelNr NOT IN (N'129899999998', N'129899999999')
ORDER BY [Set-Artikelnummer], Position

GO