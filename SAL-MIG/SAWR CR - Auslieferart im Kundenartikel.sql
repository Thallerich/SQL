UPDATE KdArti SET LiefArtID = 4
WHERE KdArti.LiefArtID != 4
  AND EXISTS (
    SELECT k.*
    FROM KdArti AS k
    JOIN OPSets ON k.ArtikelID = OPSets.ArtikelID
    JOIN Artikel ON k.ArtikelID = Artikel.ID
    JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
    WHERE (OPSets.Artikel1ID = KdArti.ArtikelID OR OPSets.Artikel2ID = KdArti.ArtikelID OR OPSets.Artikel3ID = KdArti.ArtikelID OR OPSets.Artikel4ID = KdArti.ArtikelID OR OPSets.Artikel5ID = KdArti.ArtikelID)
      AND ArtGru.Gruppe = N'CRSU'
      AND k.KundenID = KdArti.KundenID
  );

GO

UPDATE KdArti SET LiefArtID = 66
WHERE KdArti.LiefArtID != 66
  AND EXISTS (
    SELECT k.*
    FROM KdArti AS k
    JOIN OPSets ON k.ArtikelID = OPSets.ArtikelID
    JOIN Artikel ON k.ArtikelID = Artikel.ID
    JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
    WHERE (OPSets.Artikel1ID = KdArti.ArtikelID OR OPSets.Artikel2ID = KdArti.ArtikelID OR OPSets.Artikel3ID = KdArti.ArtikelID OR OPSets.Artikel4ID = KdArti.ArtikelID OR OPSets.Artikel5ID = KdArti.ArtikelID)
      AND ArtGru.Gruppe = N'CRST'
      AND k.KundenID = KdArti.KundenID
  );

GO