DECLARE @Entnahmeliste int = 2943566;

DECLARE @LiefLs TABLE (
  BestNr bigint,
  LiefID int,
  BKoID int,
  BPoID int,
  LiefLsKoID int
);

INSERT INTO @LiefLs (BestNr, LiefID, BKoID, BPoID, LiefLsKoID)
SELECT DISTINCT BKo.BestNr, BKo.LiefID, BKo.ID AS BKoID, BPo.ID AS BPoID, -1 AS LiefLsKoID
FROM BPo
JOIN BKo ON BPo.BKoID = BKo.ID
JOIN Auftrag ON BKo.IntAuftragID = Auftrag.ID
JOIN EntnKo ON EntnKo.AuftragID = Auftrag.ID
WHERE EntnKo.ID = @Entnahmeliste
  AND BPo.ID > 0;

DECLARE @LiefLsKo TABLE (
  LiefLsKoID int PRIMARY KEY
);

INSERT INTO LiefLsKo ([Status], LiefID, LsNr, Datum, SentToSap)
OUTPUT inserted.ID
INTO @LiefLsKo (LiefLsKoID)
SELECT DISTINCT 'G', LiefID, 'INTERN_' + rtrim(cast(bestnr AS NVARCHAR(20))), CAST(GETDATE() AS date), 0
FROM #lieflsko_erstellen
WHERE NOT EXISTS (
  SELECT id
  FROM lieflsko
  WHERE lieflsko.lsnr = 'INTERN_' + rtrim(cast(#lieflsko_erstellen.bestnr AS NVARCHAR(20)))
);

UPDATE #lieflsko_erstellen
SET lieflskoid = lieflsko.id
FROM Lieflsko
WHERE lieflsko.lsnr = 'INTERN_' + rtrim(cast(#lieflsko_erstellen.bestnr AS NVARCHAR(20)))
  AND LieflsKo.ID IN (SELECT LiefLsKoID FROM @LiefLsKo);

INSERT INTO lieflspo (LiefLsKoID, BPoID, Menge, Ursprungsmenge, LiefInfo)
SELECT DISTINCT LiefLsKoID, BPoID, 0, 0, 'ABS Dummy'
FROM #lieflsko_erstellen;