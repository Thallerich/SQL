IF OBJECT_ID('__BKoSMZL') IS NULL 
BEGIN
  CREATE TABLE __BKoSMZL (
    ID int PRIMARY KEY
  );
END
ELSE
BEGIN
  TRUNCATE TABLE __BKoSMZL
END;

INSERT INTO __BKoSMZL (ID)
SELECT BKo.ID
FROM BKo
JOIN BKoArt ON BKo.BKoArtID = BKoArt.ID
JOIN Lagerart ON BKo.LagerArtID = Lagerart.ID
JOIN Standort ON Lagerart.LagerID = Standort.ID
JOIN Firma ON Lagerart.FirmaID = Firma.ID
JOIN Lief ON BKo.LiefID = Lief.ID
JOIN LiefType ON Lief.LiefTypeID = LiefType.ID
LEFT JOIN Lagerart AS LiefLagerart ON BKo.LiefID = LiefLagerart.LiefID
WHERE BKo.Datum <= CAST(GETDATE() AS date)
  AND BKo.Status >= N'F'
  AND BKoArt.Kontrakt = 0
  AND Firma.SuchCode = N'FA14'
  AND Standort.SuchCode = N'SMZL'
  AND (LiefType.InternerLief = 0 OR (Lagerart.FirmaID != COALESCE(LiefLagerart.FirmaID, -1) AND COALESCE(LiefLagerart.FirmaID, -1) > -1))
  AND BKo.SentToSAP = 0
  AND BKo.ID > 0
  AND EXISTS (
    SELECT BPo.*
    FROM BPo
    WHERE BPo.BKoID = BKo.ID
      AND BPo.Pos > 0
  );