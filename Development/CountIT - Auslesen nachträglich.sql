DROP TABLE IF EXISTS #MissingChips;

SELECT EinzTeil.CurrEinzHistID AS EinzHistID, EinzTeil.ID AS EinzTeilID, AnfPo.BestaetZeitpunkt AS [DateTime], LsPo.ID AS LsPoID, AnfPo.ID AS AnfPoID, Vsa.ID AS VsaID
INTO #MissingChips
FROM Salesianer.dbo._CITMissingChips
JOIN EinzTeil ON _CITMissingChips.Sgtin96HexCode = EinzTeil.Code
JOIN AnfKo ON _CITMissingChips.PackingNumber = AnfKo.AuftragsNr
JOIN Vsa ON AnfKo.VsaID = Vsa.ID
JOIN KdArti ON KdArti.KundenID = Vsa.KundenID AND KdArti.ArtikelID = EinzTeil.ArtikelID
JOIN AnfPo ON AnfPo.AnfKoID = AnfKo.ID AND AnfPo.KdArtiID = KdArti.ID AND KdArti.Status = N'A'
JOIN LsPo ON LsPo.LsKoID = AnfKo.LsKoID AND LsPo.KdArtiID = AnfPo.KdArtiID
WHERE EinzTeil.LastScanTime < AnfPo.BestaetZeitpunkt;

GO

DECLARE @ZielNrID int = 287;
DECLARE @ActionsID int = 102;
DECLARE @ArbPlatzID int = 2247;
DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

INSERT INTO Scans (EinzHistID, EinzTeilID, [DateTime], ActionsID, ZielNrID, ArbPlatzID, Menge, LsPoID, AnfPoID, VsaID)
SELECT mc.EinzHistID, mc.EinzTeilID, mc.[DateTime], @ActionsID, @ZielNrID, @ArbPlatzID, -1, mc.LsPoID, mc.AnfPoID, mc.VsaID
FROM #MissingChips mc;

UPDATE EinzTeil SET VsaID = mc.VsaID, ZielNrID = @ZielNrID, LastActionsID = @ActionsID, LastScanTime = mc.[DateTime], LastScanToKunde = mc.[DateTime]
FROM #MissingChips mc
WHERE mc.EinzTeilID = EinzTeil.ID;

GO