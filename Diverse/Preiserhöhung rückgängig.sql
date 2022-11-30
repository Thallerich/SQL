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
  KdNr int PRIMARY KEY,
  KundenID int DEFAULT -1 NOT NULL
);

DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');
DECLARE @PeKoID int = 817;

INSERT INTO @Kunden (KdNr)
VALUES (30992), (7110), (7100), (7080), (7130), (7180), (7139), (7160), (7170), (7156), (7135), (7150), (7090), (7070), (7083), (7081), (7161), (7140), (7073), (7077), (7157), (7155), (18001), (1162), (2022), (30142), (262000), (10001805), (50001), (10001810), (10001816), (10001671), (10001815), (10001814), (10001817), (10001811), (10001822), (8888), (10001672), (10001802), (8887), (8889), (10001813), (10001799), (10001812), (8131), (10002705), (10002709), (30055), (30056), (2304), (2306), (2303), (10005512), (10004871), (25007), (10001510), (10002702), (10001928), (10001662), (10001929), (30291), (30341), (30349), (31207), (31201), (10001913), (10001938), (31209), (215055), (10001910), (10004595), (10004548), (10001915), (10001922), (10004549), (31208), (10004592), (10001921), (31204), (10001902), (21093), (10004964), (10006294), (130042), (18089), (18100), (18085), (18078), (18084), (10006188), (18101), (18087), (18094), (18088), (30045), (18096), (18093), (18083), (18074), (8031), (16250), (22003), (19053), (19054), (13331), (10016), (8101), (10005365), (25028), (100703), (250912), (272783), (271909), (271908), (271910), (270138), (10003674), (245994), (248198), (248183), (13330), (2288), (15075), (2290), (1132), (5010), (8060), (6070), (12077), (16151), (5005), (20025), (11140), (7020), (16041), (7371), (25100), (11156), (11150), (12176), (21091), (22080), (5066), (21090), (8066), (14003), (8267), (16035), (2029), (7370), (16030), (16031), (20015), (5016), (15002), (10006237), (10006238), (10006235), (10006239), (10006240), (10006236), (26007), (10005948), (2035), (22025), (19068), (30075), (10006289), (10006290), (10006292), (10006291), (10006293), (1000000238), (14030), (24090), (22013), (261331), (30393), (30777), (16078), (15007), (30515), (30524), (20144), (18033), (20140), (20153), (20145), (20146), (10005063), (19159), (20160), (20143), (20142);

UPDATE @Kunden SET KundenID = Kunden.ID
FROM Kunden
WHERE [@Kunden].KdNr = Kunden.KdNr;

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
      AND Vertrag.KundenID IN (SELECT KundenID FROM @Kunden)
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
      AND AnlageUserID_ = 9012688
      AND CAST(Anlage_ AS date) = N'2022-11-30'
      AND VonDatum = N'2022-11-30'
      AND BisDatum = N'2022-12-31';
  
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