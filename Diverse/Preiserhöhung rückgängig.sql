DECLARE @PeBack TABLE (
  KdArtiID int,
  WaschPreis money,
  LeasPreis money,
  VkPreis money,
  SonderPreis money,
  LeasPreisAbwAbWo money,
  BasisRestwert money,
  PePoID int
);

DECLARE @Kunden TABLE (
 KundenID int PRIMARY KEY CLUSTERED
);

DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');
DECLARE @PeKoID int = 817;

DECLARE @AnkuendDatum date, @AnkuendMitarbeiID int;

INSERT INTO @Kunden (KundenID)
SELECT DISTINCT Vertrag.KundenID
FROM PePo
JOIN Vertrag ON PePo.VertragID = Vertrag.ID
WHERE PePo.PeKoID = @PeKoID;

SELECT @AnkuendDatum = PeKo.AnkuendDatum, @AnkuendMitarbeiID = PeKo.AnkuendMitarbeiID
FROM PeKo
WHERE ID = @PeKoID;

BEGIN TRY

  BEGIN TRANSACTION;

    WITH LastPrArchiv AS (
      SELECT PrArchiv.KdArtiID, MAX(PrArchiv.ID) AS PrArchivID
      FROM PrArchiv
      WHERE PrArchiv.PeKoID != @PeKoID
      GROUP BY PrArchiv.KdArtiID
    )
    UPDATE KdArti SET WaschPreis = PrArchiv.WaschPreis, LeasPreis = PrArchiv.LeasPreis, VkPreis = PrArchiv.VKPreis, SonderPreis = PrArchiv.SonderPreis, LeasPreisAbwAbWo = PrArchiv.LeasPreisAbwAbWo, BasisRestwert = PrArchiv.BasisRestwert
    OUTPUT inserted.ID, inserted.WaschPreis, inserted.LeasPreis, inserted.VkPreis, inserted.SonderPreis, inserted.LeasPreisAbwAbWo, inserted.BasisRestwert, PePo.ID
    INTO @PeBack (KdArtiID, WaschPreis, LeasPreis, VkPreis, SonderPreis, LeasPreisAbwAbWo, BasisRestwert, PePoID)
    FROM KdArti
    JOIN KdBer ON KdArti.KdBerID = KdBer.ID
    JOIN Vertrag ON KdBer.VertragID = Vertrag.ID
    JOIN PePo ON PePo.VertragID = Vertrag.ID
    JOIN LastPrArchiv ON LastPrArchiv.KdArtiID = KdArti.ID
    JOIN PrArchiv ON LastPrArchiv.PrArchivID = PrArchiv.ID
    WHERE PePo.PeKoID = @PeKoID
      AND KdArti.LeasPreisPrListKdArtiID = -1
      AND KdArti.WaschPreisPrListKdArtiID = -1
      AND KdArti.SondPreisPrListKdArtiID = -1
      AND KdArti.VkPreisPrListKdArtiID = -1
      AND (KdArti.WaschPreis != PrArchiv.WaschPreis OR KdArti.LeasPreis != PrArchiv.LeasPreis OR KdArti.VkPreis != PrArchiv.VKPreis OR KdArti.SonderPreis != PrArchiv.SonderPreis OR KdArti.BasisRestwert != PrArchiv.BasisRestwert);

    INSERT INTO PrArchiv (KdArtiID, PeKoID, Datum, VkPreis, WaschPreis, SonderPreis, LeasPreis, LeasPreisAbwAbWo, BasisRestwert, Ruecknahme, MitarbeiID, Aktivierungszeitpunkt, AnlageUserID_, UserID_)
    SELECT PeBack.KdArtiID, -1 AS PeKoID, CAST(GETDATE() AS date) AS Datum, VkPreis, WaschPreis, SonderPreis, LeasPreis, LeasPreisAbwAbWo, BasisRestwert, 1 AS Ruecknahme, @UserID AS MitarbeiID, GETDATE() AS Aktivierungszeitpunkt, @UserID AS AnlageUserID_, @UserID AS UserID_
    FROM @PeBack PeBack;

    UPDATE PePo SET [Status] = N'R'
    WHERE PePo.ID IN (
      SELECT DISTINCT PePoID
      FROM @PeBack
    );

    INSERT INTO History (TableName, TableID, HistKatID, HistKanID, Zeitpunkt, MitarbeiID, VorgangsNr, Memo, [Status],  ErfasstDurchMitarbeiID, ErledigtDurchMitarbeiID, VertragID, EMailMsgID, Betreff, HistRichID, HistVorgID, ErfasstAm, ErledigtAm, AnlageUserID_, UserID_)
    SELECT N'KUNDEN' AS TableName, PeHistory.KundenID, 10125 AS HistKatID, 4 AS HistKanID, GETDATE() AS Zeitpunkt, @UserID AS MitarbeiID, NEXT VALUE FOR NEXTID_HISTORYVORGANG AS VorgangsNr, N'Preiserhöhung für Vertrag zurückgenommen, Preiserhöhung: CO2 Erhöhung 1,15% und 1,42%, Vertrag: ' + Vertrag.VertragNr AS Memo, N'S' AS [Status], @UserID AS ErfasstDurchMitarbeiID, @UserID AS ErledigtDurchMitarbeiID, Vertrag.ID AS VertragID, NULL AS EMailMsgID, N'Rücknahme Preiserhöhung' AS Betreff, 3 AS HistRichID, 1 AS HistVorgID, GETDATE() AS ErfasstAm, GETDATE() AS ErledigtAm, @UserID AS AnlageUserID_, @UserID AS UserID_
    FROM (
      SELECT DISTINCT KdArti.KundenID, KdBer.VertragID
      FROM @PeBack PeBack
      JOIN KdArti ON PeBack.KdArtiID = KdArti.ID
      JOIN KdBer ON KdArti.KdBerID = KdBer.ID
    ) AS PeHistory
    JOIN Vertrag ON PeHistory.VertragID = Vertrag.ID;

    DELETE FROM VsaTexte
    WHERE TextArtID = 13
      AND AnlageUserID_ = @AnkuendMitarbeiID
      AND CAST(Anlage_ AS date) = @AnkuendDatum
      AND KundenID IN (SELECT KundenID FROM @Kunden);
  
  COMMIT;
END TRY
BEGIN CATCH
  DECLARE @Message varchar(MAX) = ERROR_MESSAGE();
  DECLARE @Severity int = ERROR_SEVERITY();
  DECLARE @State smallint = ERROR_STATE();

  IF XACT_STATE() != 0
    ROLLBACK TRANSACTION;
 
  RAISERROR(@Message, @Severity, @State);
END CATCH;