SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

DROP TABLE IF EXISTS #ReactivateEinzHist;
GO

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');
DECLARE @runtime AS datetime2 = GETDATE();
DECLARE @msg nvarchar(max);

DECLARE @Map TABLE (
  EinzTeilID int,
  EinzHistID int
);

SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - Stornierte Teile beim Kunden 10000079 reaktivieren';
RAISERROR(@msg, 0, 1) WITH NOWAIT;

SELECT EinzHist.ID, EinzHist.EinzTeilID, CAST(NULL AS int) AS NewEinzHistID, TraeArti.ID AS TraeArtiID
INTO #ReactivateEinzHist
FROM EinzHist
JOIN TraeArti ON EinzHist.TraegerID = TraeArti.TraegerID AND EinzHist.KdArtiID = TraeArti.KdArtiID AND EinzHist.ArtGroeID = TraeArti.ArtGroeID
WHERE EinzHist.ID = (SELECT EinzTeil.CurrEinzHistID FROM EinzTeil WHERE EinzTeil.ID = EinzHist.EinzTeilID)
  AND EinzHist.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = 10000079)
  AND EinzHist.[Status] = N'5';

SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - ' + CAST(@@ROWCOUNT AS nvarchar) + N' stornierte Teile gefunden';
RAISERROR(@msg, 0, 1) WITH NOWAIT;

BEGIN TRY
  BEGIN TRANSACTION;
  
    /* Neuen EinzHist-Eintrag erstellen */
    INSERT INTO EinzHist (AdvInstID, EinzTeilID, Barcode, RentomatChip, SecondaryCode, UebernahmeCode, EinzHistTyp, PoolFkt, Archiv, [Status], EinzHistVon, EinzHistBis, KundenID, VsaID, TraegerID, TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, Eingang1, Eingang2, Eingang3, Ausgang1, Ausgang2, Ausgang3, Entnommen, PartLost, EinsatzGrund, KaufwareModus, PatchDatum, Indienst, IndienstDat, Abmeldung, AbmeldDat, AbmeldSchrFach, Ausdienst, AusdienstDat, AusdienstGrund, AusdRestw, Einzug, NachfolgeEinzHistID, RuecklaufK, AnzRepair, Kostenlos, LagerArtID, EntnPoID, WaschPrgID, WegGrundID, RestwertInfo, PatchKostenlos, StartAuftragID, StopAuftragID, Sort2, HasHinweis, HasTeileInf, LastVpsPoID, HasBilder, LastLsPoID, MsgNo, Lieferdatum, TeileSchrankInfo, FirstLsPoID, EinzugLsPoID, LastLotID, CwsBPoID, StornoMitarbeiID, StornoDateTime, LastJPGStamp, LagerOrtID, Inventarisiert, UmlagerEinzHistID, LastUmlagerEinzHistID, LastAnfPoID, CwsEraID, AnlageUserID_, UserID_)
    OUTPUT inserted.ID, inserted.EinzTeilID
    INTO @Map (EinzHistID, EinzTeilID)
    SELECT AdvInstID, EinzHist.EinzTeilID, Barcode, RentomatChip, SecondaryCode, UebernahmeCode, 1 AS EinzHistTyp, PoolFkt, 0 AS Archiv, N'N' AS [Status], @runtime AS EinzHistVon, N'2099-12-31 23:59:59.000' AS EinzHistBis, KundenID, VsaID, TraegerID, #ReactivateEinzHist.TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, Eingang1, Eingang2, Eingang3, Ausgang1, Ausgang2, Ausgang3, 1 AS Entnommen, PartLost, EinsatzGrund, KaufwareModus, ISNULL(PatchDatum, CAST(@runtime AS date)) AS PatchDatum, Indienst, IndienstDat, Abmeldung, AbmeldDat, AbmeldSchrFach, Ausdienst, AusdienstDat, AusdienstGrund, AusdRestw, Einzug, NachfolgeEinzHistID, RuecklaufK, AnzRepair, Kostenlos, LagerArtID, EntnPoID, WaschPrgID, WegGrundID, RestwertInfo, PatchKostenlos, StartAuftragID, StopAuftragID, Sort2, HasHinweis, HasTeileInf, LastVpsPoID, HasBilder, LastLsPoID, MsgNo, Lieferdatum, TeileSchrankInfo, FirstLsPoID, EinzugLsPoID, LastLotID, CwsBPoID, -1 AS StornoMitarbeiID, NULL AS StornoDateTime, LastJPGStamp, LagerOrtID, Inventarisiert, UmlagerEinzHistID, LastUmlagerEinzHistID, LastAnfPoID, CwsEraID, @userid AS AnlageUserID_, @userid AS UserID_
    FROM EinzHist
    JOIN #ReactivateEinzHist ON EinzHist.ID = #ReactivateEinzHist.ID;

    SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - ' + CAST(@@ROWCOUNT AS nvarchar) + N' neue EinzHist-Einträge erstellt';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    /* Temp-Table mit neuer ID aktualisieren */
    UPDATE #ReactivateEinzHist SET NewEinzHistID = Map.EinzHistID
    FROM @Map AS Map
    WHERE Map.EinzTeilID = #ReactivateEinzHist.EinzTeilID;

    SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - ' + CAST(@@ROWCOUNT AS nvarchar) + N' Einträge in Temp-Table aktualisiert';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    /* Alten EinzHist-Eintrag aktualisieren */
    UPDATE EinzHist SET EinzHistBis = @runtime, Archiv = 1, UserID_ = @userid
    WHERE EinzHist.ID IN (SELECT ID FROM #ReactivateEinzHist);

    SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - ' + CAST(@@ROWCOUNT AS nvarchar) + N' alte EinzHist-Einträge aktualisiert';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    /* EinzTeil-Datensatz auf neuen EinzHist-Datensatz aktualisieren */
    UPDATE EinzTeil SET CurrEinzHistID = #ReactivateEinzHist.NewEinzHistID, [Status] = N'A', UserID_ = @userid
    FROM #ReactivateEinzHist
    WHERE #ReactivateEinzHist.EinzTeilID = EinzTeil.ID;

    SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - ' + CAST(@@ROWCOUNT AS nvarchar) + N' EinzTeil-Einträge neu verknüpft';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;
  
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

SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - Fertig!';
RAISERROR(@msg, 0, 1) WITH NOWAIT;

GO

DROP TABLE #ReactivateEinzHist;
GO