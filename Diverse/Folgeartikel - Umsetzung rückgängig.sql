DECLARE @FolgeArti TABLE (
  ArtikelID int,
  FolgeArtikelID int
);

DECLARE @TraeArtiFix TABLE (
  TraeArtiID int,
  FolgeTraeArtiID int,
  DeleteFolgeTraeArti bit
);

INSERT INTO @FolgeArti
SELECT Artikel.ID AS ArtikelID, Artikel.FolgeArtikelID
FROM Artikel
WHERE Artikel.ArtikelNr IN (N'202507013271', N'203080205004', N'203080105002', N'203060105008', N'203070105015', N'203070205002', N'203080101001', N'203070205004', N'203080205002', N'202505512830', N'203071605001', N'202503003200', N'202505004418', N'202507001001', N'203003448101', N'203012042001', N'203060605008', N'203070203004', N'203070204003', N'203070401002', N'203073703001', N'203125006140', N'203140103005', N'203258101001', N'203258101166', N'203601520001')
  AND Artikel.FolgeArtikelID > 0;

INSERT INTO @TraeArtiFix
SELECT TraeArti.ID AS TraeArtiID, TraeArti.FolgeTraeArtiID, DeleteFolgeTraeArti = (
  SELECT IIF(COUNT(Teile.ID) > 0, 0, 1)
  FROM Teile
  WHERE Teile.TraeArtiID = FolgeTraeArti.ID
)
FROM TraeArti
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN TraeArti AS FolgeTraeArti ON FolgeTraeArti.ID = TraeArti.FolgeTraeArtiID
JOIN KdArti AS FolgeKdArti ON FolgeTraeArti.KdArtiID = FolgeKdArti.ID
JOIN @FolgeArti AS FolgeArti ON FolgeArti.ArtikelID = KdArti.ArtikelID AND FolgeArti.FolgeArtikelID = FolgeKdArti.ArtikelID
WHERE TraeArti.FolgeTraeArtiID > 0;

DELETE FROM TraeMass
WHERE TraeArtiID IN (
  SELECT FolgeTraeArtiID
  FROM @TraeArtiFix
  WHERE DeleteFolgeTraeArti = 1
);

UPDATE TraeArti SET FolgeTraeArtiID = -1
WHERE ID IN (
  SELECT TraeArtiID
  FROM @TraeArtiFix
  WHERE DeleteFolgeTraeArti = 1
);

DELETE FROM TraeArti
WHERE ID IN (
  SELECT FolgeTraeArtiID
  FROM @TraeArtiFix
  WHERE DeleteFolgeTraeArti = 1
);

UPDATE KdArti SET FolgeKdArtiID = -1 
WHERE KdArti.ArtikelID IN (SELECT ArtikelID FROM @FolgeArti)
  AND KdArti.FolgeKdArtiID > 0;

UPDATE Artikel SET FolgeArtikelID = -1 WHERE ID IN (SELECT ArtikelID FROM @FolgeArti);