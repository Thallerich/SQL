DROP TABLE IF EXISTS #KdArtiFalschForScan;

SELECT KdArti.ID
INTO #KdArtiFalschForScan
FROM KdArti
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
WHERE KdArti.[Status] = N'F'
  AND KdArti.ArtiOptionalBarcodiert = 0
  AND KdArti.ArtiZwingendBarcodiert = 0
  AND ArtGru.OptionalBarcodiert = 0
  AND ArtGru.ZwingendBarcodiert = 0;

UPDATE KdArti SET ArtiOptionalBarcodiert = 1
WHERE ID IN (SELECT ID FROM #KdArtiFalschForScan);

DROP TABLE #KdArtiFalschForScan;