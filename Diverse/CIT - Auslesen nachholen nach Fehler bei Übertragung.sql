SELECT EinzTeil.ID AS EinzTeilID, Vsa.ID AS VsaID, LsPo.ID AS LsPoID, AnfPo.ID AS AnfPoID, DATEADD(hour, 21, __CITScan.ConsignmentTime) AS ConsignmentTime
INTO #TmpScanToWrite
FROM EinzTeil
JOIN __CITScan ON __CITScan.HexCode = EinzTeil.Code
JOIN Vsa ON __CITScan.VsaID = Vsa.ID
JOIN LsKo ON LsKo.VsaID = Vsa.ID AND LsKo.Datum = __CITScan.DeliveryDate
JOIN Artikel ON __CITScan.ArticleNumber = Artikel.ArtikelNr
JOIN KdArti ON KdArti.ArtikelID = Artikel.ID AND KdArti.KundenID = Vsa.KundenID
JOIN LsPo ON LsPo.LsKoID = LsKo.ID AND LsPo.KdArtiID = KdArti.ID
JOIN AnfKo ON AnfKo.LsKoID = LsKo.ID AND AnfKo.AuftragsNr = __CITScan.PackingNumber
JOIN AnfPo ON AnfPo.AnfKoID = AnfKo.ID AND AnfPo.KdArtiID = KdArti.ID AND AnfPo.ArtGroeID = EinzTeil.ArtGroeID
WHERE CAST(EinzTeil.LastScanTime AS date) <= CAST(__CITScan.ConsignmentTime AS date);

GO

DECLARE @ZielNr int = 287; /* einfach alles auf GP Kabine 1 rein (Tagsys) auslesen */
DECLARE @ActionsID int = 102; /* OP auslesen */

UPDATE EinzTeil SET VsaID = x.VsaID, ZielNrID = @ZielNr, LastActionsID = @ActionsID, LastScanTime = x.ConsignmentTime, LastScanToKunde = x.ConsignmentTime
FROM #TmpScanToWrite x
WHERE x.EinzTeilID = EinzTeil.ID;

GO

DECLARE @ZielNr int = 287; /* einfach alles auf GP Kabine 1 rein (Tagsys) auslesen */
DECLARE @ActionsID int = 102; /* OP auslesen */
DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

INSERT INTO Scans (EinzTeilID, [DateTime], ActionsID, ZielNrID, Menge, LsPoID, AnfPoID, AnlageUserID_, UserID_)
SELECT EinzTeilID, ConsignmentTime, @ActionsID, @ZielNr, -1, LsPoID, AnfPoID, @UserID, @UserID
FROM #TmpScanToWrite;

GO