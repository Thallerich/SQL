DECLARE @FktCode TABLE (
  RentomatID int,
  Funktionscode nchar(8) COLLATE Latin1_General_CS_AS
);

DECLARE @Traeger TABLE (
  TraegerID int,
  Traeger varchar(8) COLLATE Latin1_General_CS_AS,
  Traegername nvarchar(80) COLLATE Latin1_General_CS_AS,
  FunktionscodeBezAlt nvarchar(40) COLLATE Latin1_General_CS_AS,
  FunktionscodeBezNeu nvarchar(40) COLLATE Latin1_General_CS_AS,
  RentoCodReplacementID int
)

INSERT INTO @FktCode (RentomatID, Funktionscode)
VALUES (42, '40'), (42, '4000'), (42, '4001'), (42, '4002'), (42, '4003'), (42, '4004'), (42, '4005'), (42, '4006'), (42, '4007'), (42, '4008'), (42, '4009'), (42, '4010'), (42, '4011'), (42, '4012'), (42, '4013'), (42, '4014'), (42, '4015'), (42, '4016'), (42, '4017'), (42, '4018'), (42, '4019'), (42, '4020'), (42, '4021'), (42, '4022'), (42, '4023'), (42, '4024'), (42, '4025'), (42, '4026'), (42, '4027'), (42, '4028'), (42, '4029'), (42, '4030'), (42, '4031'), (42, '4032'), (42, '4033'), (42, '4034'), (42, '4035'), (42, '4036'), (42, '4037'), (42, '4038'), (42, '4039'), (42, '4040'), (42, '4041'), (42, '4042'), (42, '4043'), (42, '4044'), (42, '4045'), (42, '4046'), (42, '4047'), (42, '4048'), (42, '4049'), (42, '4050'), (42, '4051'), (42, '4052'), (42, '4053'), (42, '4054'), (42, '4055'), (42, '4056'), (42, '4057'), (42, '4058'), (42, '4059'), (42, '4060'), (42, '4061'), (42, '4062'), (42, '4063'), (42, '4064'), (42, '4065'), (42, '4066'), (42, '4067'), (42, '4068'), (42, '4069'), (42, '4070'), (42, '4071'), (42, '4072'), (42, '4073'), (42, '4074'), (42, '4075'), (42, '4076'), (42, '4077'), (42, '4078'), (42, '4079'), (42, '4080'), (42, '4081'), (42, '4082'), (42, '4083'), (42, '4084'), (42, '4085'), (42, '4086'), (42, '4087'), (42, '4088'), (42, '4089'), (42, '4090'), (42, '4091'), (42, '4092'), (42, '4093'), (42, '4094'), (42, '4095');

DECLARE @RentoCodReplacementID int = (SELECT RentoCod.ID FROM RentoCod WHERE RentomatID = 42 AND Funktionscode = '100');
DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

BEGIN TRY
  BEGIN TRANSACTION;
  
    INSERT INTO @Traeger (TraegerID, Traeger, Traegername, FunktionscodeBezAlt, FunktionscodeBezNeu, RentoCodReplacementID)
    SELECT Traeger.ID, Traeger.Traeger, ISNULL(Traeger.Vorname + N' ', N'') + ISNULL(Traeger.Nachname, N''), RentoCodAlt.Bez, RentoCodNeu.Bez, @RentoCodReplacementID
    FROM Traeger WITH (UPDLOCK)
    JOIN RentoCod AS RentoCodAlt ON Traeger.RentoCodID = RentoCodAlt.ID
    CROSS JOIN RentoCod AS RentoCodNeu
    WHERE RentoCodAlt.ID IN (
        SELECT RentoCod.ID
        FROM RentoCod
        JOIN @FktCode AS FktCode ON RentoCod.RentomatID = FktCode.RentomatID AND RentoCod.Funktionscode = FktCode.Funktionscode
      )
      AND RentoCodNeu.ID = @RentoCodReplacementID;

    UPDATE Traeger SET RentoCodID = RentoCodTraeger.RentoCodReplacementID
    FROM @Traeger AS RentoCodTraeger
    WHERE RentoCodTraeger.TraegerID = Traeger.ID;

    INSERT INTO History (TableName, TableID, [Status], HistKatID, MitarbeiID, Zeitpunkt, Memo, VorgangsNr, ErfasstDurchMitarbeiID, ErfasstAm, ErledigtAm, ErledigtDurchMitarbeiID, Betreff, HistKanID, HistRichID, HistVorgID, AnlageUserID_, UserID_)
    SELECT N'TRAEGER' AS TableName, TraegerID AS TableID, N'S' AS [Status], 10120 AS HistKatID, @UserID AS MitarbeiID, GETDATE() AS Zeitpunkt,
      Memo = N'Trägerdaten geändert' + CHAR(13) + CHAR(10) + N'Träger-Nr: ' + ISNULL(Traeger, N'') + CHAR(13) + CHAR(10) + N'Name: ' + ISNULL(Traegername, N'') + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + N'geänderte Daten:' + CHAR(13) + CHAR(10) + N'Alte RentoCod-Bezeichnung: ' + ISNULL(FunktionscodeBezAlt, N'') + N' Neue RentoCod-Bezeichnung: ' + ISNULL(FunktionscodeBezNeu, N'') + N';',
      VorgangsNr = NEXT VALUE FOR NextID_HISTORYVORGANG, @UserID AS ErfasstDurchMitarbeiID, GETDATE() AS ErfasstAm, GETDATE() AS ErledigtAm, @UserID AS ErledigtDurchMitarbeiID, N'Trägerdaten geändert' AS Betreff, 4 AS HistKanID, 3 AS HistRichID, 1 AS HistVorgID, @UserID AS AnlageUserID_, @UserID AS UserID_
    FROM @Traeger;

    DELETE FROM RentoCod
    WHERE RentoCod.ID IN (
      SELECT RentoCod.ID
      FROM RentoCod
      JOIN @FktCode AS FktCode ON RentoCod.RentomatID = FktCode.RentomatID AND RentoCod.Funktionscode = FktCode.Funktionscode
    );
  
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