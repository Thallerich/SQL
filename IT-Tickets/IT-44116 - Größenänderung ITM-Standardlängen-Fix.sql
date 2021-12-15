DROP TABLE IF EXISTS #TmpArtGroeChange;
GO

CREATE TABLE #TmpArtGroeChange (
  CurrentArtGroeID int NOT NULL,
  NewArtGroeID int NOT NULL
);

GO

WITH StandardArtGroe AS (
  SELECT ArtGroe.ID AS ArtGroeID, ArtGroe.ArtikelID, GroePo.Gruppe
  FROM ArtGroe
  JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
  JOIN GroePo ON GroePo.GroeKoID = Artikel.GroeKoID AND GroePo.Groesse = ArtGroe.Groesse
  WHERE ArtGroe.StandardLaenge = 1
)
INSERT INTO #TmpArtGroeChange (CurrentArtGroeID, NewArtGroeID)
SELECT ArtGroe.ID AS CurrentArtGroeID, StandardArtGroe.ArtGroeID AS NewArtGroeID
FROM ArtGroe
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN GroePo ON GroePo.GroeKoID = Artikel.GroeKoID AND GroePo.Groesse = ArtGroe.Groesse
JOIN ITM_SMRO.[SAL\POLLNS]._BkStandardlaengen AS ITMStandardGroe ON Artikel.ArtikelNr = ITMStandardGroe.ArtikelNr COLLATE Latin1_General_CS_AS AND ArtGroe.Groesse = ITMStandardGroe.GroesseLen COLLATE Latin1_General_CS_AS
JOIN StandardArtGroe ON StandardArtGroe.ArtikelID = Artikel.ID AND StandardArtGroe.Gruppe = GroePo.Gruppe
WHERE ArtGroe.StandardLaenge = 0
  AND ArtGroe.Umlauf > 0;

GO

DECLARE @TraeArtiChange TABLE (
  TraeArtiID int NOT NULL,
  NewArtGroeID int NOT NULL
);

BEGIN TRANSACTION ArtGroeUpdate WITH MARK N'IT-44116';

  UPDATE Teile SET ArtGroeID = ArtGroeChange.NewArtGroeID
  OUTPUT inserted.TraeArtiID, inserted.ArtGroeID
  INTO @TraeArtiChange (TraeArtiID, NewArtGroeID)
  FROM Teile
  JOIN #TmpArtGroeChange AS ArtGroeChange ON Teile.ArtGroeID = ArtGroeChange.CurrentArtGroeID
  JOIN Lagerart ON Teile.LagerArtID = Lagerart.ID
  WHERE Lagerart.LagerID IN (
    SELECT Standort.ID
    FROM Standort
    WHERE Standort.SuchCode IN (N'ORAD', N'BUKA')
  );

  UPDATE Teile SET TraeArtiID = TraeArti.ID
  FROM Teile
  JOIN @TraeArtiChange AS TraeArtiChange ON Teile.TraeArtiID = TraeArtiChange.TraeArtiID
  JOIN TraeArti ON Teile.TraegerID = TraeArti.TraegerID AND Teile.KdArtiID = TraeArti.KdArtiID AND TraeArtiChange.NewArtGroeID = TraeArti.ArtGroeID;

  UPDATE TraeArti SET ArtGroeID = TraeArtiChange.NewArtGroeID
  FROM TraeArti
  JOIN @TraeArtiChange AS TraeArtiChange ON TraeArtiChange.TraeArtiID = TraeArti.ID
  WHERE NOT EXISTS (
    SELECT ta.*
    FROM TraeArti AS ta
    WHERE ta.TraegerID = TraeArti.TraegerID AND ta.KdArtiID = TraeArti.KdArtiID AND ta.ArtGroeID = TraeArtiChange.NewArtGroeID
  );

COMMIT TRANSACTION ArtGroeUpdate;
/* ROLLBACK TRANSACTION ArtGroeUpdate; */

GO