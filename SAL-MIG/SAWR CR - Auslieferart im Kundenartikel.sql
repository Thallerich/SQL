UPDATE KdArti SET LiefArtID = 66
WHERE KdArti.LiefArtID != 66
  AND EXISTS (
    SELECT k.*
    FROM KdArti AS k
    JOIN OPSets ON k.ArtikelID = OPSets.ArtikelID
    WHERE (OPSets.Artikel1ID = KdArti.ArtikelID OR OPSets.Artikel2ID = KdArti.ArtikelID OR OPSets.Artikel3ID = KdArti.ArtikelID OR OPSets.Artikel4ID = KdArti.ArtikelID OR OPSets.Artikel5ID = KdArti.ArtikelID)
      AND k.KundenID = KdArti.KundenID
  );