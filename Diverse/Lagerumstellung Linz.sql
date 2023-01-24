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
DECLARE @LokalLagerID1 int = (SELECT ID FROM Standort WHERE SuchCode = N'WOLX' AND Lager = 1);
DECLARE @LokalLagerID2 int = (SELECT ID FROM Standort WHERE SuchCode = N'WOL3' AND Lager = 1);
DECLARE @CurrentDate datetime = DATETIMEFROMPARTS(DATEPART(year, GETDATE()), DATEPART(month, GETDATE()), DATEPART(day, GETDATE()), 0, 0, 0, 0);
DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

DECLARE @KdNr int = 30285;

DECLARE @SQLText nvarchar(max) = N'
SELECT N''ERNEUTBUCHEN;'' + EinzHist.Barcode
FROM EinzHist
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
JOIN Lagerart ON EinzHist.LagerartID = Lagerart.ID
JOIN TeileBPo ON TeileBPo.EinzHistID = EinzHist.ID
JOIN BPo ON TeileBPo.BPoID = BPo.ID
JOIN BKo ON BPo.BKoID = BKo.ID
JOIN Lief ON BKo.LiefID = Lief.ID
WHERE EinzHist.IsCurrEinzHist = 1
  AND EinzHist.PoolFkt = 0
  AND EinzHist.AltenheimModus = 0
  AND EinzHist.[Status] BETWEEN N''E'' AND N''I''
  AND EinzHist.Entnommen = 0
  AND ((@KdNr > 0 AND Kunden.KdNr = @KdNr) OR (@KdNr <= 0 AND 1 = 1))
  AND StandBer.LagerID = @LagerID
  AND (StandBer.LokalLagerID = @LokalLagerID1 OR StandBer.LokalLagerID = @LokalLagerID2)
  AND ((Lief.LiefNr = 100) OR (BKo.[Status] < N''F''))
  AND NOT EXISTS (
    SELECT Scans.*
    FROM Scans
    WHERE Scans.EinzHistID = EinzHist.ID
      AND Scans.[DateTime] > @CurrentDate
      AND Scans.ActionsID = 46
      AND Scans.AnlageUserID_ = @UserID
  );
';

EXEC sp_executesql @SQLText, N'@LagerID int, @LokalLagerID1 int, @LokalLagerID2 int, @CurrentDate datetime, @UserID int, @KdNr int', @LagerID, @LokalLagerID1, @LokalLagerID2, @CurrentDate, @UserID, @KdNr;

GO