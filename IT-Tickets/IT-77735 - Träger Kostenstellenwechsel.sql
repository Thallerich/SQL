DECLARE @kdnr int = 10001878;
DECLARE @vsanr int = 8;
DECLARE @ksst nvarchar(20) = N'2';

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');
DECLARE @abteilid int, @neuabteil nvarchar(50);

SELECT @abteilid = Abteil.ID, @neuabteil = Abteil.Bez + N' (' + Abteil.Abteilung + N')'
FROM Abteil
WHERE Abteil.Abteilung = @ksst
  AND Abteil.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = @kdnr);

DECLARE @Traeger TABLE (
  TraegerID int,
  Alt_AbteilID int,
  Neu_AbteilID int
);

BEGIN TRY
  BEGIN TRANSACTION;

    UPDATE Traeger SET AbteilID = @abteilid, Memo = CONCAT(N'KoSt-Wechsel von „' + Abteil.Bez + N' (' + Abteil.Abteilung + N')' + N'“ nach „' + @neuabteil + N'“ durch THALST am ' + FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss'), CHAR(13), CHAR(10), Memo)
    OUTPUT inserted.ID, deleted.AbteilID, inserted.AbteilID
    INTO @Traeger (TraegerID, Alt_AbteilID, Neu_AbteilID)
    FROM Abteil
    WHERE Traeger.AbteilID = Abteil.ID
      AND Traeger.ID IN (
        SELECT Traeger.ID
        FROM Traeger
        WHERE Traeger.VsaID = (
            SELECT Vsa.ID
            FROM Vsa
            WHERE Vsa.KundenID = (
                SELECT Kunden.ID
                FROM Kunden
                WHERE Kunden.KdNr = @kdnr
              )
              AND Vsa.VsaNr = @vsanr
          )
          AND Traeger.Traeger NOT IN ('0464', '0642')
          AND (Traeger.Ausdienst >= N'2024/01' OR Traeger.Ausdienst IS NULL)
          AND Traeger.AbteilID != @abteilid
      );
  
    INSERT INTO History (TableName, TableID, [Status], HistKatID, MitarbeiID, Zeitpunkt, Memo, VorgangsNr, ErfasstAm, ErledigtAm, ErledigtDurchMitarbeiID, Betreff, HistKanID, HistRichID, HistVorgID, AnlageUserID_, UserID_)
    SELECT N'TRAEGER' AS TableName, Traeger.ID AS TableID, N'S' AS [Status], 10158 AS HistKatID, @userid AS MitarbeiID, GETDATE() AS Zeitpunkt, Memo = N'KoSt-Wechsel von „' + Alt_Abteil.Bez + N' (' + Alt_Abteil.Abteilung + N')' + N'“ nach „' + Neu_Abteil.Bez + N' (' + Neu_Abteil.Abteilung + N')' + N'“', NEXT VALUE FOR NextID_HISTORYVORGANG AS VorgangsNr, GETDATE() AS ErfasstAm, GETDATE() AS ErledigtAm, @userid AS ErledigtDurchMitarbeiID, N'Kostenstellen-Wechsel auf Trägerebene' AS Betreff, 4 AS HistKanID, 3 AS HistRichID, 1 AS HistVorgID, @userid AS AnlageUserID_, @userid AS UserID_
    FROM Traeger
    JOIN @Traeger AS AlteredTraeger ON Traeger.ID = AlteredTraeger.TraegerID
    JOIN Abteil AS Alt_Abteil ON AlteredTraeger.Alt_AbteilID = Alt_Abteil.ID
    JOIN Abteil AS Neu_Abteil ON AlteredTraeger.Neu_AbteilID = Neu_Abteil.ID;

    INSERT INTO History (TableName, TableID, [Status], HistKatID, MitarbeiID, Zeitpunkt, Memo, VorgangsNr, ErfasstAm, ErledigtAm, ErledigtDurchMitarbeiID, Betreff, HistKanID, HistRichID, HistVorgID, AnlageUserID_, UserID_)
    SELECT N'TRAEGER' AS TableName, Traeger.ID AS TableID, N'S' AS [Status], 10120 AS HistKatID, @userid AS MitarbeiID, GETDATE() AS Zeitpunkt, Memo = N'Trägerdaten geändert' + CHAR(13) + CHAR(10) + N'Träger-Nr: ' + Traeger.Traeger + CHAR(13) + CHAR(10) + N'Name: ' + CONCAT(Traeger.Vorname, N' ', Traeger.Nachname) + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + N'geänderte Daten:' + CHAR(13) + CHAR(10) + N'Kostenstelle: ' + Alt_Abteil.Bez + N' (' + Alt_Abteil.Abteilung + N')' + N'Neue Kostenstelle: ' + Neu_Abteil.Bez + N' (' + Neu_Abteil.Abteilung + N')', NEXT VALUE FOR NextID_HISTORYVORGANG AS VorgangsNr, GETDATE() AS ErfasstAm, GETDATE() AS ErledigtAm, @userid AS ErledigtDurchMitarbeiID, N'Trägerdaten geändert' AS Betreff, 4 AS HistKanID, 3 AS HistRichID, 1 AS HistVorgID, @userid AS AnlageUserID_, @userid AS UserID_
    FROM Traeger
    JOIN @Traeger AS AlteredTraeger ON Traeger.ID = AlteredTraeger.TraegerID
    JOIN Abteil AS Alt_Abteil ON AlteredTraeger.Alt_AbteilID = Alt_Abteil.ID
    JOIN Abteil AS Neu_Abteil ON AlteredTraeger.Neu_AbteilID = Neu_Abteil.ID;
  
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