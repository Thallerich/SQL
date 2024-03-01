WITH ArtiLief1 AS (
  SELECT al.ArtikelID, al.LiefID, al.StandortID, al.VonDatum, al.ID AS ArtiLiefID1
  FROM ArtiLief al
  WHERE al.LiefPackMenge = 1
)
SELECT N'ABSCHAFFEN;ARTILIEF;' + CAST(ArtiLief.ID AS nvarchar) + N';' + CAST(ArtiLief1.ArtiLiefID1 AS nvarchar) + N';1'
FROM ArtiLief
JOIN ArtiLief1 ON ArtiLief.ArtikelID = ArtiLief1.ArtikelID AND ArtiLief.LiefID = ArtiLief1.LiefID AND ArtiLief.StandortID = ArtiLief1.StandortID AND ArtiLief.VonDatum = ArtiLief1.VonDatum
WHERE LiefPackMenge = 0
  AND (ArtiLief.BisDatum IS NULL OR ArtiLief.BisDatum >= CAST(GETDATE() AS date));

GO

UPDATE ArtiLief SET ArtiLief.LiefPackMenge = 1
WHERE ArtiLief.ID IN (
  SELECT ArtiLief.ID
  FROM ArtiLief
  WHERE ArtiLief.LiefPackMenge = 0
    AND (ArtiLief.BisDatum IS NULL OR ArtiLief.BisDatum >= CAST(GETDATE() AS date))
    AND NOT EXISTS (
      SELECT al.*
      FROM ArtiLief al
      WHERE al.ArtikelID = ArtiLief.ArtikelID
        AND al.LiefID = ArtiLief.LiefID
        AND al.StandortID = ArtiLief.StandortID
        AND al.VonDatum = ArtiLief.VonDatum
        AND al.LiefPackMenge = 1
    )
);

GO