/* System-Checkliste 198 - Preislisten neu anwenden */

/* VSAANF existiert bereits - alten auf inaktiven, neuen auf aktiv */
/* Häkchen bei Kundenartikel und Status auf aktiv statt falsch geliefert */

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

DROP TABLE IF EXISTS #TeileHarmonisierung, #VsaAnfHarmonisierung, #AnfPoHarmonisierung;
GO

DECLARE @msg nvarchar(max);
DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

DECLARE @ArtiMap TABLE (
  ArtikelID_Alt int NOT NULL DEFAULT -1,
  ArtikelNr_Alt nchar(15) COLLATE Latin1_General_CS_AS NOT NULL,
  ArtikelID_Neu int NOT NULL DEFAULT -1,
  ArtikelNr_Neu nchar(15) COLLATE Latin1_General_CS_AS NOT NULL,
  ArtGroeID_Neu int NOT NULL DEFAULT -1
);

DECLARE @Archive TABLE (
  KdArtiID int,
  LeasPreis money,
  WaschPreis money,
  SonderPreis money,
  VKPreis money,
  BasisRestwert money,
  LeasPreisAbwAbWo money
);

INSERT INTO @ArtiMap (ArtikelNr_Alt, ArtikelNr_Neu)
VALUES (N'118408010001', N'GH0100G');
/*
       (N'118416010001', N'GH0200G'),
       (N'118416011001', N'GH0246G'),
       (N'118420010001', N'GH0240'),
       (N'110616242901', N'7199T0'),
       (N'110616242701', N'7199T0');
*/

UPDATE @ArtiMap SET ArtikelID_Alt = ISNULL((SELECT ID FROM Artikel WHERE ArtikelNr = ArtikelNr_Alt), -9),
                    ArtikelID_Neu = ISNULL((SELECT ID FROM Artikel WHERE ArtikelNr = ArtikelNr_Neu), -9),
                    ArtGroeID_Neu = ISNULL((SELECT TOP 1 ID FROM ArtGroe WHERE ArtikelID = (SELECT ID FROM Artikel WHERE ArtikelNr = ArtikelNr_Neu) AND ArtGroe.Status = N'A' ORDER BY Groesse ASC), -9);

IF EXISTS (SELECT * FROM @ArtiMap WHERE ArtikelID_Alt < 0 OR ArtikelID_Neu < 0)
BEGIN
  RAISERROR('ArtikelIDs konnte nicht vollständig ermittelt werden', 16, 1);
  SET NOEXEC ON;
END;

SET @msg = FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss') + ' - Starte Artikelharmonisierung!';
RAISERROR(@msg, 0, 1) WITH NOWAIT;

SET @msg = FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss') + ' - ---------------------------------------------------';
RAISERROR(@msg, 0, 1) WITH NOWAIT;

BEGIN TRY
  BEGIN TRANSACTION;
    
    /* EinzHist + EinzTeil */

    SELECT EinzTeil.ID AS EinzTeilID, EinzTeil.CurrEinzHistID AS EinzHistID, ArtiMap.ArtikelID_Neu, ArtiMap.ArtGroeID_Neu
    INTO #TeileHarmonisierung
    FROM EinzTeil
    JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
    JOIN @ArtiMap AS ArtiMap ON EinzTeil.ArtikelID = ArtiMap.ArtikelID_Alt
    WHERE EinzHist.EinzHistTyp != 3
      AND EinzHist.Status != N'5'
      AND EinzHist.Status < N'Y';

    SET @msg = FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss') + ' - ' + FORMAT(@@ROWCOUNT, N'N0') + ' Teiledatensätze zu aktualisieren!';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    UPDATE EinzTeil SET ArtikelID = #TeileHarmonisierung.ArtikelID_Neu, ArtGroeID = #TeileHarmonisierung.ArtGroeID_Neu, UserID_ = @userid
    FROM #TeileHarmonisierung
    WHERE EinzTeil.ID = #TeileHarmonisierung.EinzTeilID;

    SET @msg = FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss') + ' - ' + FORMAT(@@ROWCOUNT, N'N0') + ' EinzTeil aktualisiert!';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    UPDATE EinzHist SET ArtikelID = #TeileHarmonisierung.ArtikelID_Neu, ArtGroeID = #TeileHarmonisierung.ArtGroeID_Neu, UserID_ = @userid
    FROM #TeileHarmonisierung
    WHERE EinzHist.ID = #TeileHarmonisierung.EinzHistID;

    SET @msg = FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss') + ' - ' + FORMAT(@@ROWCOUNT, N'N0') + ' EinzHist aktualisiert!';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    /* Check and fix errors */
    UPDATE EinzHist SET ArtikelID = EinzTeil.ArtikelID, ArtGroeID = EinzTeil.ArtGroeID
    FROM EinzTeil
    WHERE EinzTeil.CurrEinzHistID = EinzHist.ID
      AND (EinzTeil.ArtikelID != EinzHist.ArtikelID OR EinzTeil.ArtGroeID != EinzHist.ArtGroeID);

    SET @msg = FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss') + ' - ' + FORMAT(@@ROWCOUNT, N'N0') + ' Fehler behoben!';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    /* KdArti */

    SELECT VsaAnf.ID AS VsaAnfID, VsaAnf.VsaID, KdArti.ID AS KdArtiID_Alt, KdArtiNeu.ID AS KdArtiID, IIF(VsaAnf.ArtGroeID > 0, ArtiMap.ArtGroeID_Neu, -1) AS ArtGroeID, ArtiMap.ArtikelID_Neu, KdArti.Variante, VsaAnf.AbteilID, CAST(NULL AS tinyint) AS Rank, HasExisting = IIF((
      SELECT COUNT(*)
      FROM VsaAnf AS v
      WHERE v.VsaID = VsaAnf.VsaID
        AND v.KdArtiID = KdArtiNeu.ID
        AND v.ArtGroeID = IIF(VsaAnf.ArtGroeID > 0, ArtiMap.ArtGroeID_Neu, -1)
    ) > 0, 1, 0)
    INTO #VsaAnfHarmonisierung
    FROM VsaAnf
    JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
    JOIN @ArtiMap AS ArtiMap ON KdArti.ArtikelID = ArtiMap.ArtikelID_Alt
    LEFT JOIN KdArti AS KdArtiNeu ON ArtiMap.ArtikelID_Neu = KdArtiNeu.ArtikelID AND KdArti.KundenID = KdArtiNeu.KundenID AND KdArti.Variante = KdArtiNeu.Variante
    WHERE KdArti.ErsatzFuerKdArtiID < 0;

    SET @msg = FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss') + ' - ' + FORMAT(@@ROWCOUNT, N'N0') + ' anforderbare Artikel zu aktualisieren!';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;
    
    /* TODO: Preislisten - KdArti.?PrListKdArtiID */
    /* TODO: Ersatzartikel - KdArti.ErsatzFuerKdArtiID */
    /* wenn mehrere Artikel zu einem zusammengefasst werden, wird der zuletzt angelegte Kundenartikel davon als Vorlage verwendet */
    INSERT INTO KdArti ([Status], KundenID, ArtikelID, KdBerID, Variante, LeasPreis, WaschPreis, SonderPreis, VKPreis, Bestellerfassung, LiefArtID, WaschPrgID, AfaWochen, MaxWaschen, BasisRestwert, Lieferwochen, Vorlaeufig, KeineAnfPo, WebArtikel, LsAusblenden, BDE, EigentumID, IstBestandAnpass, Vertragsartikel, CheckPackmenge, ArtiZwingendBarcodiert, ArtiOptionalBarcodiert, AnlageUserID_, UserID_)
    OUTPUT inserted.ID, inserted.LeasPreis, inserted.WaschPreis, inserted.SonderPreis, inserted.VkPreis, inserted.BasisRestwert, inserted.LeasPreisAbwAbWo
    INTO @Archive (KdArtiID, LeasPreis, WaschPreis, SonderPreis, VKPreis, BasisRestwert, LeasPreisAbwAbWo)
    SELECT [Status], KundenID, ArtikelID, KdBerID, Variante, LeasPreis, WaschPreis, SonderPreis, VKPreis, Bestellerfassung, LiefArtID, WaschPrgID, AfaWochen, MaxWaschen, BasisRestwert, Lieferwochen, Vorlaeufig, KeineAnfPo, WebArtikel, LsAusblenden, BDE, EigentumID, IstBestandAnpass, Vertragsartikel, CheckPackmenge, ArtiZwingendBarcodiert, ArtiOptionalBarcodiert, AnlageUserID_, UserID_
    FROM (
      SELECT DISTINCT IIF(KdArti.LeasPreis = 0 AND KdArti.WaschPreis = 0, N'F', N'A') AS [Status], KdArti.KundenID, #VsaAnfHarmonisierung.ArtikelID_Neu AS ArtikelID, KdArti.KdBerID, KdArti.Variante, KdArti.LeasPreis, KdArti.WaschPreis, KdArti.SonderPreis, KdArti.VKPreis, KdArti.Bestellerfassung, KdArti.LiefArtID, KdArti.WaschPrgID, KdArti.AfaWochen, KdArti.MaxWaschen, KdArti.BasisRestwert, KdArti.Lieferwochen, KdArti.Vorlaeufig, KdArti.KeineAnfPo, KdArti.WebArtikel, KdArti.LsAusblenden, KdArti.BDE, KdArti.EigentumID, KdArti.IstBestandAnpass, KdArti.Vertragsartikel, KdArti.CheckPackmenge, KdArti.ArtiZwingendBarcodiert, KdArti.ArtiOptionalBarcodiert, @userid AS AnlageUserID_, @userid AS UserID_, DENSE_RANK() OVER (PARTITION BY KdArti.KundenID, #VsaAnfHarmonisierung.ArtikelID_Neu, KdArti.Variante ORDER BY KdArti.ID DESC) AS Rank
      FROM #VsaAnfHarmonisierung
      JOIN KdArti ON #VsaAnfHarmonisierung.KdArtiID_Alt = KdArti.ID
      WHERE #VsaAnfHarmonisierung.KdArtiID IS NULL
    ) AS UniqueInsert
    WHERE Rank = 1;

    SET @msg = FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss') + ' - ' + FORMAT(@@ROWCOUNT, N'N0') + ' Kundenartikel eingefügt!';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    INSERT INTO PrArchiv (KdArtiID, Datum, LeasPreis, WaschPreis, SonderPreis, VKPreis, BasisRestwert, LeasPreisAbwAbWo, MitarbeiID, Aktivierungszeitpunkt, AnlageUserID_, UserID_)
    SELECT KdArtiID, CAST(GETDATE() AS date) AS Datum, LeasPreis, WaschPreis, SonderPreis, VKPreis, BasisRestwert, LeasPreisAbwAbWo, @userid, GETDATE(), @userid, @userid
    FROM @Archive;

    SET @msg = FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss') + ' - ' + FORMAT(@@ROWCOUNT, N'N0') + ' Preisarchiv-Einträge eingefügt!';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    UPDATE #VsaAnfHarmonisierung SET KdArtiID = KdArtiNeu.ID
    FROM KdArti, KdArti AS KdArtiNeu
    WHERE #VsaAnfHarmonisierung.KdArtiID_Alt = KdArti.ID
      AND #VsaAnfHarmonisierung.ArtikelID_Neu = KdArtiNeu.ArtikelID AND KdArti.KundenID = KdArtiNeu.KundenID AND KdArti.Variante = KdArtiNeu.Variante
      AND #VsaAnfHarmonisierung.KdArtiID IS NULL;
    
    SEt @msg = FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss') + ' - temporäre Arbeitstabellen mit neu angelegten Kundenartikeln aktualisiert!';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    UPDATE #VsaAnfHarmonisierung SET Rank = x.Rank
    FROM (
      SELECT VsaAnfID, HasExisting + DENSE_RANK() OVER (PARTITION BY VsaID, KdArtiID, ArtGroeID ORDER BY VsaAnfID DESC) AS Rank
      FROM #VsaAnfHarmonisierung
    ) AS x
    WHERE x.VsaAnfID = #VsaAnfHarmonisierung.VsaAnfID;

    SET @msg = FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss') + ' - ' + FORMAT(@@ROWCOUNT, N'N0') + ' VsaAnf-Vorbereitungstabelle aktualisiert!';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    /* VsaAnf */

    SELECT AnfPo.ID AS AnfPoID, AnfPo.AnfKoID, KdArti.ID AS KdArtiID_Alt, KdArtiNeu.ID AS KdArtiID, IIF(AnfPo.ArtGroeID > 0, ArtiMap.ArtGroeID_Neu, -1) AS ArtGroeID, ArtiMap.ArtikelID_Neu, KdArti.Variante, AnfPo.AbteilID, AnfPo.Angefordert
    INTO #AnfPoHarmonisierung
    FROM AnfPo
    JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
    JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID
    JOIN @ArtiMap AS ArtiMap ON KdArti.ArtikelID = ArtiMap.ArtikelID_Alt
    LEFT JOIN KdArti AS KdArtiNeu ON ArtiMap.ArtikelID_Neu = KdArtiNeu.ArtikelID AND KdArti.KundenID = KdArtiNeu.KundenID AND KdArti.Variante = KdArtiNeu.Variante
    WHERE AnfKo.Lieferdatum >= CAST(GETDATE() AS date)
      AND AnfKo.[Status] <= N'F'
      AND AnfPo.Angefordert > 0
      AND KdArti.ErsatzFuerKdArtiID < 0;

    SET @msg = FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss') + ' - ' + FORMAT(@@ROWCOUNT, N'N0') + ' Anforderungspositionen zu aktualisieren!';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    UPDATE VsaAnf SET KdArtiID = #VsaAnfHarmonisierung.KdArtiID, ArtGroeID = #VsaAnfHarmonisierung.ArtGroeID, UserID_ = @userid
    FROM #VsaAnfHarmonisierung
    WHERE VsaAnf.ID = #VsaAnfHarmonisierung.VsaAnfID
      AND #VsaAnfHarmonisierung.Rank = 1;

    SET @msg = FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss') + ' - ' + FORMAT(@@ROWCOUNT, N'N0') + ' VsaAnf aktualisiert!';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    UPDATE VsaAnf SET [Status] = N'E', UserID_ = @userid
    FROM #VsaAnfHarmonisierung
    WHERE VsaAnf.ID = #VsaAnfHarmonisierung.VsaAnfID
      AND VsaAnf.[Status] < N'E'
      AND #VsaAnfHarmonisierung.Rank > 1;

    SET @msg = FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss') + ' - ' + FORMAT(@@ROWCOUNT, N'N0') + ' VsaAnf auf "nur einbuchen" gestellt!';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    /* AnfPo */
    /* TODO: zukünftige Packzettel auch anpassen - neuer Artikel soll angefordert sein */
    WITH NewAnfPo AS (
      SELECT AnfKoID, KdArtiID, ArtGroeID, SUM(Angefordert) AS Angefordert
      FROM #AnfPoHarmonisierung
      GROUP BY AnfKoID, KdArtiID, ArtGroeID
    )
    UPDATE AnfPo SET Angefordert = AnfPo.Angefordert + NewAnfPo.Angefordert, UserID_ = @userid
    FROM NewAnfPo
    WHERE AnfPo.AnfKoID = NewAnfPo.AnfKoID
      AND AnfPo.KdArtiID = NewAnfPo.KdArtiID
      AND AnfPo.ArtGroeID = NewAnfPo.ArtGroeID
      AND AnfPo.Angefordert != NewAnfPo.Angefordert;

    SET @msg = FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss') + ' - ' + FORMAT(@@ROWCOUNT, N'N0') + ' Anforderungsposition - Mengen bei bestehenden Positionen aktualisiert!';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    WITH NewAnfPo AS (
      SELECT AnfKoID, KdArtiID, ArtGroeID, AbteilID, SUM(Angefordert) AS Angefordert
      FROM #AnfPoHarmonisierung
      GROUP BY AnfKoID, KdArtiID, ArtGroeID, AbteilID
    )
    INSERT INTO AnfPo (AnfKoID, KdArtiID, ArtGroeID, Angefordert, AbteilID, UserID_)
    SELECT AnfKoID, KdArtiID, ArtGroeID, Angefordert, AbteilID, @userid
    FROM NewAnfPo
    WHERE NOT EXISTS (
      SELECT *
      FROM AnfPo
      WHERE AnfPo.AnfKoID = NewAnfPo.AnfKoID
        AND AnfPo.KdArtiID = NewAnfPo.KdArtiID
        AND AnfPo.ArtGroeID = NewAnfPo.ArtGroeID
    );

    SET @msg = FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss') + ' - ' + FORMAT(@@ROWCOUNT, N'N0') + ' neue Anforderungspositionen erstellt!';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    UPDATE AnfPo SET Angefordert = 0, UserID_ = @userid
    FROM #AnfPoHarmonisierung
    WHERE AnfPo.ID = #AnfPoHarmonisierung.AnfPoID;
    
    SET @msg = FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss') + ' - ' + FORMAT(@@ROWCOUNT, N'N0') + ' alte Anforderungspositionen auf Menge = 0 gesetzt!';
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

SET @msg = FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss') + ' - Artikelharmonisierung abgeschlossen!';
RAISERROR(@msg, 0, 1) WITH NOWAIT;

GO

SET NOEXEC OFF;
GO