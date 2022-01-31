DECLARE @CloseOrder TABLE (
  BPoID int,
  BKoID int,
  Stornomenge int
);

INSERT INTO @CloseOrder (BPoID, BKoID, Stornomenge)
SELECT BPo.ID AS BPoID, BPo.BKoID, BPo.Menge - BPo.LiefMenge AS OffeneMenge
FROM BKo
JOIN BPo ON BPo.BKoID = BKo.ID
JOIN ArtGroe ON BPo.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Standort AS Lager ON BKo.LagerID = Lager.ID
WHERE BPo.Menge > BPo.LiefMenge
  AND BKo.[Status] BETWEEN N'F' AND N'K'
  AND Artikel._IsHAWA = 1
  AND BKo.LiefID = (SELECT Lief.ID FROM Lief WHERE Lief.LiefNr = 100)
  AND BPo.LatestLiefABKoID > 0
  --AND Lager.SuchCode IN (N'ARNO', N'SCHI');
  --AND BKo.BestNr IN (1068638, 1072852, 1072852, 1072852, 1072852, 1076181, 1076590, 412000437, 412000564, 412000660, 412000679, 412000680, 412000710, 412000710, 412000710, 412000710, 412000717, 412000724, 412000724, 412000724);
  AND Lager.FirmaID = 5260
  AND BKo.Datum <= N'2021-03-31';

UPDATE BPo SET Menge = BPo.Menge - CloseOrder.Stornomenge, ZusatzText = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm', N'de-AT') + N' - THALST: Bestellung automatisiert abgeschlossen, verbliebene offene Menge wurde AdvanTex-intern storniert!' + CHAR(13) + CHAR(10) + ISNULL(ZusatzText, N'')
FROM @CloseOrder AS CloseOrder
WHERE CloseOrder.BPoID = BPo.ID;

UPDATE BKo SET Status = N'M', MemoIntern = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm', N'de-AT') + N' - THALST: Bestellung automatisiert abgeschlossen, verbliebene offene Menge wurde AdvanTex-intern storniert!' + CHAR(13) + CHAR(10) + ISNULL(MemoIntern, N'')
FROM @CloseOrder AS CloseOrder
WHERE CloseOrder.BKoID = BKo.ID
  AND NOT EXISTS (
    SELECT BPo.*
    FROM BPo
    WHERE BPo.BKoID = BKo.ID
      AND BPo.Menge > BPo.LiefMenge
  );