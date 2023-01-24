DECLARE @LagerID int = (SELECT ID FROM Standort WHERE SuchCode = N'SMZL' AND Lager = 1);
DECLARE @LokalLagerID int = (SELECT ID FROM Standort WHERE SuchCode = N'WOEN' AND Lager = 1);
DECLARE @TargetLagerArtID int = (SELECT ID FROM Lagerart WHERE Lagerart = N'WOLIBKNU');

DECLARE @KdNr int = 0;

SELECT N'EINZHIST_LAGERWECHSEL;' + CAST(EinzHist.ID AS nvarchar) + N';' + CAST(@TargetLagerArtID AS nvarchar) + N';1'
FROM EinzHist
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
JOIN TeileBPo ON TeileBPo.EinzHistID = EinzHist.ID
JOIN BPo ON TeileBPo.BPoID = BPo.ID
JOIN BKo ON BPo.BKoID = BKo.ID
JOIN Lief ON BKo.LiefID = Lief.ID
JOIN Lagerart ON EinzHist.LagerArtID = Lagerart.ID
WHERE EinzHist.IsCurrEinzHist = 1
  AND EinzHist.PoolFkt = 0
  AND EinzHist.AltenheimModus = 0
  AND EinzHist.[Status] BETWEEN N'E' AND N'I'
  AND EinzHist.Entnommen = 0
  AND ((@KdNr > 0 AND Kunden.KdNr = @KdNr) OR (@KdNr <= 0 AND 1 = 1))
  AND StandBer.LagerID = @LagerID
  AND StandBer.LokalLagerID = @LokalLagerID
  AND ((Lief.LiefNr = 100) OR (BKo.[Status] < N'F'))
  AND Lagerart.LagerID != @LagerID
  AND NOT EXISTS (
    SELECT Scans.*
    FROM Scans
    WHERE Scans.EinzHistID = EinzHist.ID
      AND Scans.[DateTime] > N'2023-01-23 13:00:00'
      AND Scans.ActionsID = 45
      AND Scans.AnlageUserID_ = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST')
  );

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ TODO: Teile die bereits auf Entnahmelisten stehen, nicht neu buchen                                                       ++ */
/* ++       Nur Teile auf einer Bestellung an SMZL oder auf nicht gedruckter Bestellung an extern                               ++ */
/* ++ ᓚᘏᗢ -- Implemented 2023-01-23 08:14:00 - ThalSt                                                                          ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ ♨︎_♨︎  Lenzing muss nur erneut buchen ausgeführt werden!                                                                   ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @LagerID int = (SELECT ID FROM Standort WHERE SuchCode = N'SMZL' AND Lager = 1);
DECLARE @LokalLagerID int = (SELECT ID FROM Standort WHERE SuchCode = N'WOEN' AND Lager = 1);
DECLARE @TargetLagerArtID int = (SELECT ID FROM Lagerart WHERE Lagerart = N'WOLIBKNU');

DECLARE @KdNr int = 0;

SELECT N'ERNEUTBUCHEN;' + EinzHist.Barcode
FROM EinzHist
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
JOIN Lagerart ON EinzHist.LagerartID = Lagerart.ID
WHERE EinzHist.IsCurrEinzHist = 1
  AND EinzHist.PoolFkt = 0
  AND EinzHist.AltenheimModus = 0
  AND EinzHist.[Status] BETWEEN N'E' AND N'I'
  AND EinzHist.Entnommen = 0
  AND ((@KdNr > 0 AND Kunden.KdNr = @KdNr) OR (@KdNr <= 0 AND 1 = 1))
  AND StandBer.LagerID = @LagerID
  AND StandBer.LokalLagerID = @LokalLagerID
  AND Lagerart.LagerID = @LagerID
  AND EXISTS (
    SELECT Scans.*
    FROM Scans
    WHERE Scans.EinzHistID = EinzHist.ID
      AND Scans.[DateTime] > N'2023-01-23 13:00:00'
      AND Scans.ActionsID = 45
      AND Scans.AnlageUserID_ = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST')
  )
  AND NOT EXISTS (
    SELECT Scans.*
    FROM Scans
    WHERE Scans.EinzHistID = EinzHist.ID
      AND Scans.[DateTime] > N'2023-01-23 13:00:00'
      AND Scans.ActionsID = 46
      AND Scans.AnlageUserID_ = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST')
  );

GO