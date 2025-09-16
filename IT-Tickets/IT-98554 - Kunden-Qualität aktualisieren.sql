SET XACT_ABORT ON;
GO

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = UPPER(REPLACE(ORIGINAL_LOGIN(), N'SAL\', N'')));

DECLARE @Kunden TABLE (ID int PRIMARY KEY);
DECLARE @KundQualChange TABLE (KundenID int PRIMARY KEY, OldKundQualID int, NewKundQualID int);

INSERT INTO @Kunden
SELECT Kunden.ID
FROM Kunden
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN KundQual ON Kunden.KundQualID = KundQual.ID
WHERE KdGf.KurzBez = 'MED'
  AND Kunden.[Status] = 'A'
  AND Kunden.KundQualID != 7
  AND EXISTS (
    SELECT 1
    FROM VsaBer
    JOIN KdBer ON VsaBer.KdBerID = KdBer.ID
    JOIN Vsa ON VsaBer.VsaID = Vsa.ID
    JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
    WHERE Vsa.KundenID = Kunden.ID
      AND Vsa.[Status] = 'A'
      AND KdBer.BereichID IN (SELECT ID FROM Bereich WHERE Bereich = 'BK')
      AND StandBer.ProduktionID = (SELECT ID FROM Standort WHERE SuchCode = 'GRAZ')
  );

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE Kunden SET KundQualID = 7, UserID_ = @userid
    OUTPUT inserted.ID, deleted.KundQualID, inserted.KundQualID INTO @KundQualChange (KundenID, OldKundQualID, NewKundQualID)
    WHERE ID IN (SELECT ID FROM @Kunden);

    INSERT INTO History (TableName, TableID, [Status], HistKatID, MitarbeiID, Zeitpunkt, Memo, VorgangsNr, ErfasstAm, ErfasstDurchMitarbeiID, ErledigtAm, ErledigtDurchMitarbeiID, Betreff, HistKanID, HistRichID, HistVorgID, AnlageUserID_, UserID_)
    SELECT 'KUNDEN' AS TableName, KQC.KundenID AS TableID, 'S' AS [Status], 10087 AS HistKatID, @userid AS MitarbeiD, GETDATE() AS Zeitpunkt, 'Option „Qualität:“ geändert von „' + OldKundQual.KundQualBez + '“ auf „' + NewKundQual.KundQualBez + '“.' AS Memo, NEXT VALUE FOR NextID_HISTORYVORGANG AS VorgangsNr, GETDATE() AS ErfasstAm, @userid AS ErfasstDurchMitarbeiID, GETDATE() AS ErledigtAm, @userid AS ErledigtDurchMitarbeiID, 'Qualitätsstufe des Kunden' AS Betreff, 4 AS HistKanID, 3 AS HistRichID, 1 AS HistVorgID, @userid AS AnlageUserID_, @userid AS UserID_
    FROM @KundQualChange AS KQC
    JOIN KundQual AS OldKundQual ON KQC.OldKundQualID = OldKundQual.ID
    JOIN KundQual AS NewKundQual ON KQC.NewKundQualID = NewKundQual.ID;
  
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