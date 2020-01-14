DECLARE @KdNr int = 10003083;
DECLARE @Artikel nchar(15) = N'70V1';

DECLARE @TraeArti TABLE (
  TraeArtiID int,
  FolgeTraeArtiID int,
  DeleteFolge bit
);

WITH TraeArtiTeil AS (
  SELECT Teile.TraeArtiID, COUNT(Teile.ID) AS AnzahlTeile
  FROM Teile
  JOIN Vsa ON Teile.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  WHERE Kunden.KdNr = @KdNr
  GROUP BY Teile.TraeArtiID
),
FolgeTraeArti AS (
  SELECT TraeArti.ID
  FROM TraeArti
  JOIN KdArti AS FolgeKdArti ON TraeArti.KdArtiID = FolgeKdArti.ID
  JOIN KdArti AS UrsprungKdArti ON UrsprungKdArti.FolgeKdArtiID = FolgeKdArti.ID
  JOIN Artikel ON UrsprungKdArti.ArtikelID = Artikel.ID
  JOIN Kunden ON UrsprungKdArti.KundenID = Kunden.ID
  WHERE Kunden.KdNr = @KdNr
    AND Artikel.ArtikelNr = @Artikel
)
INSERT INTO @TraeArti
SELECT TraeArti.ID AS TraeArtiID, TraeArti.FolgeTraeArtiID, IIF(TraeArtiTeil.AnzahlTeile > 0, 0, 1) AS AnzahlTeile
FROM TraeArti
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN FolgeTraeArti ON FolgeTraeArti.ID = TraeArti.FolgeTraeArtiID
LEFT OUTER JOIN TraeArtiTeil ON TraeArtiTeil.TraeArtiID = TraeArti.FolgeTraeArtiID
WHERE Kunden.KdNr = @KdNr
  AND Artikel.ArtikelNr = @Artikel;

UPDATE TraeArti SET FolgeTraeArtiID = -1, FolgeArtZwingend = 0 WHERE ID IN (
  SELECT TraeArtiID FROM @TraeArti
);

DELETE FROM TraeArti WHERE ID IN (
  SELECT FolgeTraeArtiID
  FROM @TraeArti
  WHERE DeleteFolge = 1
);

UPDATE KdArti SET FolgeKdArtiID = -1
WHERE ArtikelID = (SELECT ID FROM Artikel WHERE ArtikelNr = @Artikel)
  AND KundenID = (SELECT ID FROM Kunden WHERE KdNr = @KdNr);