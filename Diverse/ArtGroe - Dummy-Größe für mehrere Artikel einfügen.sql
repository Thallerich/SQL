DECLARE @ArtGroe TABLE (
  ArtikelID int,
  ArtGroeID int
);

DECLARE @Bestand TABLE (
  ArtGroeID int,
  BestandID int,
  LagerartID int
);

INSERT INTO ArtGroe (ArtikelID, Groesse, Status, EKPreis)
OUTPUT inserted.ArtikelID, inserted.ID AS ArtGroeID
INTO @ArtGroe
SELECT Artikel.ID AS ArtikelID, N'-' AS Groesse, N'A' AS Status, Artikel.EkPreis
FROM Artikel
WHERE Artikel.ID IN (SELECT ArtikelID FROM Wozabal.dbo.__EWohneArtGroe)
  AND NOT EXISTS (SELECT ArtGroe.* FROM ArtGroe WHERE ArtGroe.ArtikelID = Artikel.ID);

WITH FillBestand
AS (
  SELECT ArtGroe.ID ArtGroeID, LagerArt.ID LagerArtID
  FROM ArtGroe, LagerArt, Artikel
  WHERE NOT EXISTS (
      SELECT ID
      FROM Bestand
      WHERE Bestand.LagerArtID = LagerArt.ID
        AND Bestand.ArtGroeID = ArtGroe.ID
        AND (
          SELECT COUNT(*) AS x
          FROM BestOrt
          WHERE BestandID = Bestand.ID
          ) > 0
      )
    AND ArtGroe.ID IN (SELECT ArtGroeID FROM @ArtGroe)
    AND LagerArt.ArtiTypeID = 1
    AND LagerArt.ID <> - 1
    AND LagerArt.OhneBestand = 0
    AND ArtGroe.ID <> - 1
    AND Artikel.ID = ArtGroe.ArtikelID
    AND Artikel.ArtiTypeID = 1
  )
INSERT INTO Bestand (ArtGroeID, LagerArtID, GleitPreis, Warenwert)
OUTPUT inserted.ArtGroeID, inserted.ID AS BestandID, inserted.LagerartID
INTO @Bestand
SELECT x.ArtGroeID, x.LagerArtID, Artikel.EkPreis, 0.0
FROM FillBestand x, Artikel, ArtGroe, ArtGru
WHERE NOT EXISTS (
    SELECT ID
    FROM Bestand
    WHERE Bestand.LagerArtID = x.LagerArtID
      AND Bestand.ArtGroeID = x.ArtGroeID
    )
  AND x.ArtGroeID = ArtGroe.ID
  AND ArtGroe.ArtikelID = Artikel.ID
  AND Artikel.ArtGruID = ArtGru.ID
  AND ArtGru.OhneBestand = 0;

INSERT INTO BestOrt (BestandID, LagerOrtID, ArtikelID, Stamm)
SELECT x.BestandID, LagerArt.DummyLagerOrtID, ArtGroe.ArtikelID, 1
FROM @Bestand AS x, ArtGroe, LagerArt
WHERE NOT EXISTS (
    SELECT ID
    FROM BestOrt
    WHERE BestOrt.BestandID = x.BestandID
    )
  AND x.BestandID > 0
  AND x.ArtGroeID = ArtGroe.ID
  AND x.LagerArtID = LagerArt.ID;