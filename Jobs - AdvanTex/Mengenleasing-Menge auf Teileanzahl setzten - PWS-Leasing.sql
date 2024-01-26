/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Ticket: IT-78497                                                                                                          ++ */
/* ++   Bei bestimmten Kunden soll Bewohnerwäsche als Leasing abgerechnet werden.                                               ++ */
/* ++   Dazu überträgt dieses Skript die Anzahl an Teilen in den zugehörigen Mengenleasing-Eintrag.                             ++ */
/* ++   Hintergrund: Keine "echte" Bewohnerwäsche ist, sondern Bekleidung, die in einem PWS-Betrieb produziert werden soll!     ++ */
/* ++                                                                                                                           ++ */
/* ++ Author: Stefan THALLER - 2024-01-26                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @Kunde TABLE (
  KdNr int PRIMARY KEY CLUSTERED
);

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Liste mit Kundennummern, die vom Skript betrachtet werden!                                                                ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

INSERT INTO @Kunde
VALUES (10003460);

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Skript beginnt hier - ab hier nichts mehr ändern!                                                                         ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #VsaLeasMenge;

DECLARE @curweek nchar(7) = (SELECT [Week].Woche FROM [Week] WHERE CAST(GETDATE() AS date) BETWEEN [Week].VonDat AND [Week].BisDat);
DECLARE @userid int = (SELECT MitarbeiID FROM #AdvSession);

CREATE TABLE #VsaLeasMenge (
  VsaLeasID int PRIMARY KEY CLUSTERED,
  VsaID int,
  ArtikelNr nchar(15),
  ArtikelBez nvarchar(60),
  Indienst nchar(7),
  VsaLeasMenge int,
  TeileMenge int,
  Differenz AS TeileMenge - VsaLeasMenge
);

INSERT INTO #VsaLeasMenge (VsaLeasID, VsaID, ArtikelNr, ArtikelBez, Indienst, VsaLeasMenge, TeileMenge)
SELECT VsaLeas.ID AS VsaLeasID, VsaLeas.VsaID, Artikel.ArtikelNr, Artikel.ArtikelBez, VsaLeas.Indienst, VsaLeas.Menge, MengeTeile = (
  SELECT COUNT(EinzHist.ID)
  FROM EinzTeil
  JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
  JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
  WHERE EinzHist.KdArtiID = KdArti.ID
    AND EinzHist.VsaID = Vsaleas.VsaID
    AND EinzHist.TraeArtiID > 0
    AND EinzTeil.AltenheimModus != 0
    AND EinzHist.EinzHistTyp = 1
    AND EinzHist.Archiv = 0
    AND EinzHist.Kostenlos = 0
    AND ISNULL(EinzHist.Indienst, N'2099/52') <= @curweek
    AND ISNULL(EinzHist.Ausdienst, N'2099/52') > @curweek
    AND Traeger.[Status] NOT IN (N'K', N'P')
)
FROM VsaLeas
JOIN KdArti ON VsaLeas.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
WHERE Kunden.KdNr IN (SELECT KdNr FROM @Kunde)
  AND KdBer.BereichID = (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = N'PWS');

DELETE FROM #VsaLeasMenge WHERE VsaLeasMenge = TeileMenge;

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE VsaLeas SET Menge = #VsaLeasMenge.TeileMenge
    FROM #VsaLeasMenge
    WHERE #VsaLeasMenge.VsaLeasID = VsaLeas.ID;

    INSERT INTO History (TableName, TableID, [Status], HistKatID, MitarbeiID, Zeitpunkt, Memo, VorgangsNr, ErfasstAm, ErfasstDurchMitarbeiID, ErledigtAm, ErledigtDurchMitarbeiID, Betreff, HistKanID, HistRichID, HistVorgID, AnlageUserID_, UserID_)
    SELECT
      TableName = N'VSA',
      TableID = VsaID,
      [Status] = N'S',
      HistKatID = 10089,
      MitarbeiID = @userid,
      Zeitpunkt = GETDATE(),
      Memo = N'Änderung der Leasing-Menge für Artikel „' + CONCAT(RTRIM(ArtikelNr), N' ', ArtikelBez) + N'“:' + CHAR(13) + CHAR(10) + N'Indienstwoche: ' + ISNULL(Indienst, N'') + CHAR(13) + CHAR(10) + N'alte Menge: ' + CAST(VsaLeasMenge AS nvarchar) + CHAR(13) + CHAR(10) + N'Differenz: ' + CAST(Differenz AS nvarchar) + CHAR(13) + CHAR(10) + N'neue Menge: ' + CAST(TeileMenge AS nvarchar),
      VorgangsNr = NEXT VALUE FOR NextID_HISTORYVORGANG,
      ErfasstAm = GETDATE(),
      ErfasstDurchMitarbeiID = @userid,
      ErledigtAm = GETDATE(),
      ErledigtDurchMitarbeiID = @userid,
      Betreff = N'Änderung im Mengen-Leasing',
      HistKanID = 4,
      HistRichID = 3,
      HistVorgID = 1,
      AnlageUserID_ = @userid,
      UserID_ = @userid
    FROM #VsaLeasMenge;
  
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

DROP TABLE IF EXISTS #VsaLeasMenge;