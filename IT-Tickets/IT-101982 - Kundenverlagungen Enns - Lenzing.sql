SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

DROP TABLE IF EXISTS #VsaStandKon, #VsaTourUpdate;
GO

SELECT Vsa.ID AS VsaID, StandKonNeu.ID AS StandKonID, StandKonAlt.ID AS StandKonIDAlt, StandKonAlt.StandKonBez AS StandKonBezAlt, StandKonNeu.StandKonBez AS StandKonBezNeu, _IT101982_StandKon.KontrolleXMal, _IT101982_StandKon.VsaName2, _IT101982_StandKon.VsaName3
INTO #VsaStandKon
FROM _IT101982_StandKon
JOIN Vsa ON _IT101982_StandKon.VsaNr = Vsa.VsaNr
JOIN Kunden ON _IT101982_StandKon.KdNr = Kunden.KdNr AND Vsa.KundenID = Kunden.ID
JOIN StandKon AS StandKonAlt ON Vsa.StandKonID = StandKonAlt.ID
JOIN StandKon AS StandKonNeu ON _IT101982_StandKon.StandKonBez = StandKonNeu.StandKonBez;

GO

/* SELECT VsaTour.ID AS VsaTourID, VsaTour.VsaID, VsaTour.TourenID, TourenNeu.ID AS TourenNeuID, VsaTour.KdBerID, Bereich.ID AS BereichID, _IT101982_Touren.FolgeNeu, VsaTour.Holen, VsaTour.Bringen, VsaTour.StopZeit, VsaTour.AusliefDauer, _IT101982_Touren.VonDatum AS VonDatum_TourNeu, _IT101982_Touren.BisDatum AS BisDatum_TourAlt, _IT101982_Touren.MinBearbTage, Vsa.VsaNr, Touren.Tour, Bereich.BereichBez
INTO #VsaTourUpdate
FROM VsaTour
JOIN Vsa ON VsaTour.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Touren ON VsaTour.TourenID = Touren.ID
JOIN KdBer ON VsaTour.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN _IT101982_Touren ON Kunden.KdNr = _IT101982_Touren.KdNr AND Vsa.VsaNr = _IT101982_Touren.VsaNr AND Bereich.BereichBez = _IT101982_Touren.Bereich AND Touren.Tour = _IT101982_Touren.Tour AND VsaTour.Folge = _IT101982_Touren.Folge
JOIN Touren AS TourenNeu ON _IT101982_Touren.TourNeu = TourenNeu.Tour
WHERE CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum; 

GO */

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = UPPER(REPLACE(ORIGINAL_LOGIN(), N'SAL\', N'')));
DECLARE @msg nvarchar(max);

BEGIN TRY
  BEGIN TRANSACTION;

    UPDATE Vsa SET StandKonID = #VsaStandKon.StandKonID, KontrolleXMal = #VsaStandKon.KontrolleXMal, Name2 = #VsaStandKon.VsaName2, Name3 = #VsaStandKon.VsaName3, UserID_ = @userid
    FROM #VsaStandKon
    WHERE Vsa.ID = #VsaStandKon.VsaID;

    SET @msg = CAST(@@ROWCOUNT AS nvarchar) + N' VSA-Standortkonfigurationen wurden geändert.';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    INSERT INTO History (TableName, TableID, [Status], HistKatID, MitarbeiID, Zeitpunkt, Memo, VorgangsNr, ErfasstAm, ErfasstDurchMitarbeiID, ErledigtAm, ErledigtDurchMitarbeiID, Betreff, HistKanID, HistRichID, HistVorgID, AnlageUserID_, UserID_)
    SELECT 'VSA' AS TableName, VsaID AS TableID, 'S' AS [Status], 10043 AS HistKatID, @userid AS MitarbeiID, GETDATE() AS Zeitpunkt, 'VSA-Standortkonfigurations-Wechsel von „' + #VsaStandKon.StandKonBezAlt + '" zu „' + #VsaStandKon.StandKonBezNeu + '“', NEXT VALUE FOR NextID_HISTORYVORGANG AS VorgangsNr, GETDATE() AS ErfasstAm, @userid AS ErfasstDurchMitarbeiID, GETDATE() AS ErledigtAm, @userid AS ErledigtDurchMitarbeiID, 'Standortkonfiguration VSA geändert' AS Betreff, 4 AS HistKanID, 3 AS HistRichID, 1 AS HistVorgID, @userid AS AnlageUserID_, @userid AS UserID_
    FROM #VsaStandKon;

    SET @msg = CAST(@@ROWCOUNT AS nvarchar) + N' VSA-Standortkonfigurations-Historieneinträge wurden erstellt.';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;
    
    /*   
    UPDATE VsaTour SET BisDatum = #VsaTourUpdate.BisDatum_TourAlt, UserID_ = @userid
    FROM #VsaTourUpdate
    WHERE #VsaTourUpdate.VsaTourID = VsaTour.ID;

    SET @msg = CAST(@@ROWCOUNT AS nvarchar) + N' VSA-Touren wurden angepasst.';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    INSERT INTO History (TableName, TableID, [Status], HistKatID, MitarbeiID, BereichID, Zeitpunkt, Memo, VorgangsNr, ErfasstAm, ErfasstDurchMitarbeiID, ErledigtAm, ErledigtDurchMitarbeiID, Betreff, HistKanID, HistRichID, HistVorgID, AnlageUserID_, UserID_)
    SELECT 'VSA' AS TableName, VsaID AS TableID, 'S' AS [Status], 10025 AS HistKatID, @userid AS MitarbeiID, BereichID, GETDATE() AS Zeitpunkt, 'VSA-Tour (VSA-Nr.: ' + CAST(VsaNr AS varchar) + '; Tour: ' + Tour + '; Bereich: ' + BereichBez + ') bearbeitet', NEXT VALUE FOR NextID_HISTORYVORGANG AS VorgangsNr, GETDATE() AS ErfasstAm, @userid AS ErfasstDurchMitarbeiID, GETDATE() AS ErledigtAm, @userid AS ErledigtDurchMitarbeiID, 'VSA-Tour überarbeitet' AS Betreff, 4 AS HistKanID, 3 AS HistRichID, 1 AS HistVorgID, @userid AS AnlageUserID_, @userid AS UserID_
    FROM #VsaTourUpdate;

    SET @msg = CAST(@@ROWCOUNT AS nvarchar) + N' VSA-Tour-Historieneinträge (Bearbeitung) wurden erstellt.';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    INSERT INTO VsaTour (VsaID, TourenID, KdBerID, Folge, Holen, Bringen, StopZeit, AusliefDauer, VonDatum, BisDatum, AnlageUserID_, UserID_)
    SELECT VsaID, TourenNeuID, KdBerID, FolgeNeu AS Folge, Holen, Bringen, StopZeit, AusliefDauer, VonDatum_TourNeu AS VonDatum, '2099-12-31' AS BisDatum, @userid AS AnlageUserID_, @userid AS UserID_
    FROM #VsaTourUpdate;

    SET @msg = CAST(@@ROWCOUNT AS nvarchar) + N' neue VSA-Touren wurden angelegt.';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    INSERT INTO History (TableName, TableID, [Status], HistKatID, MitarbeiID, BereichID, Zeitpunkt, Memo, VorgangsNr, ErfasstAm, ErfasstDurchMitarbeiID, ErledigtAm, ErledigtDurchMitarbeiID, Betreff, HistKanID, HistRichID, HistVorgID, AnlageUserID_, UserID_)
    SELECT 'VSA' AS TableName, VsaID AS TableID, 'S' AS [Status], 10025 AS HistKatID, @userid AS MitarbeiID, BereichID, GETDATE() AS Zeitpunkt, 'VSA-Tour (VSA-Nr.: ' + CAST(VsaNr AS varchar) + '; Tour: ' + Tour + '; Bereich: ' + BereichBez + ') neu angelegt', NEXT VALUE FOR NextID_HISTORYVORGANG AS VorgangsNr, GETDATE() AS ErfasstAm, @userid AS ErfasstDurchMitarbeiID, GETDATE() AS ErledigtAm, @userid AS ErledigtDurchMitarbeiID, 'VSA-Tour neu angelegt' AS Betreff, 4 AS HistKanID, 3 AS HistRichID, 1 AS HistVorgID, @userid AS AnlageUserID_, @userid AS UserID_
    FROM #VsaTourUpdate;

    SET @msg = CAST(@@ROWCOUNT AS nvarchar) + N' neue VSA-Tour-Historieneinträge (Neuanlage) wurden erstellt.';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;
    */

  COMMIT;
END TRY
BEGIN CATCH
  DECLARE @Message varchar(MAX) = ERROR_MESSAGE();
  DECLARE @Severity int = ERROR_SEVERITY();
  DECLARE @State smallint = ERROR_STATE();
  
  IF XACT_STATE() != 0
    ROLLBACK TRANSACTION;
  
  RAISERROR(@Message, @Severity, @State) WITH NOWAIT;
END CATCH;

GO

DECLARE curVsaUpdate CURSOR FOR
  SELECT VsaID, StandKonID, StandKonIDAlt
  FROM #VsaStandKon;

DECLARE @VsaID bigint, @StandKonIDNeu bigint, @StandKonIDAlt bigint, @rownumber int = 1, @maxrows int;
DECLARE @msg nvarchar(max);

SELECT @maxrows = COUNT(*) FROM #VsaStandKon;

OPEN curVsaUpdate;
FETCH NEXT FROM curVsaUpdate INTO @VsaID, @StandKonIDNeu, @StandKonIDAlt;

WHILE @@FETCH_STATUS = 0
BEGIN
  EXEC dbo.SdcUpdateForVSA @VsaID = @VsaID, @OldStandKonID = @StandKonIDAlt, @NewStandKonID = @StandKonIDNeu;

  SELECT @msg = N'Running SDC Update for VSA row number ' + CAST(@rownumber AS nvarchar) + N' / ' + CAST(@maxrows AS nvarchar);
  RAISERROR(@msg, 0, 1) WITH NOWAIT;

  SET @rownumber += 1;

  FETCH NEXT FROM curVsaUpdate INTO @VsaID, @StandKonIDNeu, @StandKonIDAlt;
END;

CLOSE curVsaUpdate;
DEALLOCATE curVsaUpdate;

GO