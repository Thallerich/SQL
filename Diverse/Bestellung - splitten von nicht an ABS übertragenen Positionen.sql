DECLARE @User int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');
DECLARE @BestNr int = 1058926;

DECLARE @NewBKo TABLE (
  BKoID int
);

INSERT INTO BKo (BestNr, Status, BKoArtID, LiefID, MWStSatz, LagerArtID, LagerID, AnlageUserID_, UserID_)
OUTPUT inserted.ID
INTO @NewBKo
SELECT NEXT VALUE FOR NextID_BESTNR AS BestNr, N'A' AS Status, BKo.BKoArtID, BKo.LiefID, BKo.MWStSatz, BKo.LagerArtID, BKo.LagerID, @User AS AnlageUserID_, @User AS UserID_
FROM BKo
WHERE BKo.BestNr = @BestNr;

UPDATE BPo SET BPo.BKoID = NewBKo.BKoID, BPo.Einzelpreis = ArtGroe.EKPreis
FROM BPo
JOIN ArtGroe ON BPo.ArtGroeID = ArtGroe.ID
CROSS JOIN @NewBKo AS NewBKo
WHERE BPo.BKoID = (SELECT ID FROM BKo WHERE BestNr = @BestNr)
  AND BPo.LatestLiefABKoID < 0;

UPDATE BKo SET BKo.NettoWert = BPoSummen.Nettowert, BKo.MWStBetrag = ROUND(BPoSummen.Nettowert * BKo.MWStSatz / 100, 2), BKo.BruttoWert = ROUND(BPoSummen.Nettowert * (1 + BKo.MWStSatz / 100), 2)
FROM BKo
JOIN (
  SELECT BPo.BKoID, SUM(BPo.Menge * BPo.Einzelpreis) AS Nettowert
  FROM BPo
  JOIN @NewBKo AS NewBKo ON NewBKo.BKoID = BPo.BKoID
  GROUP BY BPo.BKoID
) AS BPoSummen ON BPoSummen.BKoID = BKo.ID;

UPDATE BKo SET BKo.NettoWert = BPoSummen.Nettowert, BKo.MWStBetrag = ROUND(BPoSummen.Nettowert * BKo.MWStSatz / 100, 2), BKo.BruttoWert = ROUND(BPoSummen.Nettowert * (1 + BKo.MWStSatz / 100), 2), BKo.Status = N'F'
FROM BKo
JOIN (
  SELECT BPo.BKoID, SUM(BPo.Menge * BPo.Einzelpreis) AS Nettowert
  FROM BPo
  WHERE BPo.BKoID = (SELECT BKo.ID FROM BKo WHERE BKo.BestNr = @BestNr)
  GROUP BY BPo.BKoID
) AS BPoSummen ON BPoSummen.BKoID = BKo.ID;

SELECT BKo.*
FROM BKo
WHERE BKo.ID IN (
  SELECT BKoID
  FROM @NewBKo
);