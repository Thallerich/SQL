/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* Wochenabschlüsse bei den Kunden wiederholen, um die AbtKdArW.Art korrekt auf "M" (Monatsabschluss) zu setzen.                   */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #KdList;
GO

SELECT Kunden.ID AS KundenID, KdBer.ID AS KdBerID, Kunden.KdNr, Kunden.SuchCode, Kunden.[Status] AS Kundenstatus, Bereich.BereichBez, KdBer.[Status] AS KdBerStatus, FakFreq.FakFreqBez, KdBer.FakBisDat
INTO #KdList
FROM KdBer
JOIN Kunden ON KdBer.KundenID = Kunden.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN FakFreq ON KdBer.FakFreqID = FakFreq.ID
WHERE Kunden.FirmaID = (SELECT ID FROM Firma WHERE SuchCode = N'SMSK')
  AND FakFreq.FakFreqBez = N'4-wöchentlich'
  AND Kunden.AdrArtID = 1;

GO

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = UPPER(REPLACE(ORIGINAL_LOGIN(), N'SAL\', N'')));

BEGIN TRY
  BEGIN TRANSACTION;

    UPDATE KdBer SET FakFreqID = -1 /* Standard (4/4/5) */, UserID_ = @userid
    WHERE KdBer.ID IN (SELECT KdBerID FROM #KdList);
  
    UPDATE KdArti SET KdArti.LeasPreis = LeasPreisProWo.LeasPreisProWo, KdArti.LeasPreisAbwAbWo = LeasPreisProWo.LeasPreisAbwAbWoProWo, UserID_ = @userid
    FROM KdArti
    CROSS APPLY dbo.advFunc_GetLeasPreisProWo(KdArti.ID) LeasPreisProWo
    WHERE KdArti.KdBerID IN (SELECT KdBerID FROM #KdList)
      AND (KdArti.LeasPreis != LeasPreisProWo.LeasPreisProWo OR KdArti.LeasPreisAbwAbWo != LeasPreisProWo.LeasPreisAbwAbWoProWo);

    INSERT INTO History (TableName, TableID, HistKatID, HistKanID, Zeitpunkt, SachbearID, MitarbeiID, VorgangsNr, Memo, [Status], Protokoll, ErfasstDurchMitarbeiID, RueckInfoKunde, ErledigtDurchMitarbeiID, Dauer, VertragID, BereichID, DocumentID, FahrtID, WFKoID, EMailMsgID, Betreff, NextTimeOut, HistUrsaID, HistRichID, HistVorgID, ErfasstAm, ErledigtAm, Referenz, ReklVeruID, WebUserID, ParentID, Ort, SerienParentID, Visible)
    SELECT
      TableName = 'KUNDEN',
      TableID = #KdList.KundenID,
      HistKatID = 10041,
      HistKanID = 4,
      Zeitpunkt = GETDATE(),
      SachbearID = -1,
      MitarbeiID = @userid,
      VorgangsNr = NEXT VALUE FOR NextID_HISTORYVORGANG,
      Memo = 'manuelle Änderung an Periodenleasing-Einstellungen:' + CHAR(13) + CHAR(10) + 'Kundenbereich: „' + #KdList.BereichBez + '“' + CHAR(13) + CHAR(10) + 'Abrechnung: „4-wöchentlich“ -> „Standard (4/4/5)“' + CHAR(13) + CHAR(10) + 'abgerechnet bis: ' + FORMAT(#KdList.FakBisDat, 'dd.MM.yyyy') + ' -> -',
      [Status] = 'S',
      Protokoll = 0,
      ErfasstDurchMitarbeiID = @userid,
      RueckInfoKunde = 0,
      ErledigtDurchMitarbeiID = @userid,
      Dauer = 0,
      VertragID = -1,
      BereichID = -1,
      DocumentID = -1,
      FahrtID = -1,
      WFKoID = -1,
      EMailMsgID = NULL,
      Betreff = 'Faktura-Frequenzanpassung',
      NextTimeOut = NULL,
      HistUrsaID = -1,
      HistRichID = 3,
      HistVorgID = 1,
      ErfasstAm = GETDATE(),
      ErledigtAm = GETDATE(),
      Referenz = NULL,
      ReklVeruID = -1,
      WebUserID = -1,
      ParentID = -1,
      Ort = NULL,
      SerienParentID = -1,
      Visible = 1
    FROM #KdList;

    UPDATE Kunden SET BRLaufID = -1 /* Monatliche Abrechnung */
    WHERE Kunden.ID IN (SELECT KundenID FROM #KdList)
      AND BrLaufID = (SELECT ID FROM BrLauf WHERE BrLaufBez = '4-wöchentlich SK');

    INSERT INTO VsaTexte (KundenID, TextArtID, Memo, VonDatum, BisDatum, AnlageUserID_, UserID_)
    SELECT DISTINCT
      KundenID = #KdList.KundenID,
      TextArtID = 13,
      Memo = N'Vážený zákazník,' + CHAR(13) + CHAR(10) + N'Naša spoločnosť s účinnosťou od 01.01.2026 prechádza z aktuálne 4-týždňovej fakturácie na mesačnú fakturáciu. V najbližšom období od nás obdržíte návrh Dodatku k Zmluve, v ktorom bude táto zmenu obsiahnutá. Chceme Vás požiadať o následne spätné zaslanie Vami podpísaného Dodatku k Zmluve.' + CHAR(13) + CHAR(10) + N'Ďakujeme' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + N'SALESIANER MIETTEX s. r. o.',
      VonDatum = CAST(GETDATE() AS date),
      BisDatum = '2026-03-31',
      AnlageUserID_ = @userid,
      UserID_ = @userid
    FROM #KdList;

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