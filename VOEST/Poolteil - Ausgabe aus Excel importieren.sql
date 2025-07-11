/*
CREATE TABLE _VOESTStudentenEntnahme (
  KdNr int NOT NULL,
  VsaNr int NOT NULL,
  TNr nvarchar(8) COLLATE Latin1_General_CS_AS NOT NULL,
  Barcode varchar(33) COLLATE Latin1_General_CS_AS NOT NULL,
  EinzHistID int,
  EinzTeilID int,
  TraegerID int,
  TraeArtiID int,
  KdArtiID int,
  ArtikelID int,
  ArtGroeID int,
  VsaID int,
  KundenID int,
  Variante nvarchar(4) COLLATE Latin1_General_CS_AS
);
*/

/*
  TRUNCATE TABLE _VOESTStudentenEntnahme;
*/

SET NOCOUNT ON;
GO

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE _VOESTStudentenEntnahme SET EinzHistID = EinzHist.ID, EinzTeilID = EinzTeil.ID, ArtikelID = EinzHist.ArtikelID, ArtGroeID = EinzHist.ArtGroeID, Variante = KdArti.Variante
    FROM EinzHist
    JOIN EinzTeil ON EinzTeil.CurrEinzHistID = EinzHist.ID
    JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
    WHERE EinzHist.Barcode = _VOESTStudentenEntnahme.Barcode
      AND EinzHist.ID = (SELECT EinzTeil.CurrEinzHistID FROM EinzTeil WHERE EinzTeil.ID = EinzHist.EinzTeilID);

    UPDATE _VOESTStudentenEntnahme SET TraegerID = Traeger.ID, VsaID = Vsa.ID, KundenID = Kunden.ID
    FROM Kunden
    JOIN Vsa ON Vsa.KundenID = Kunden.ID 
    JOIN Traeger ON Traeger.VsaID = Vsa.ID 
    WHERE Kunden.KdNr = _VOESTStudentenEntnahme.KdNr
      AND Vsa.VsaNr = _VOESTStudentenEntnahme.VsaNr
      AND TRY_CAST(Traeger.Traeger AS int) = TRY_CAST(_VOESTStudentenEntnahme.TNr AS int);

    UPDATE _VOESTStudentenEntnahme SET KdArtiID = KdArti.ID
    FROM KdArti
    WHERE KdArti.ArtikelID = _VOESTStudentenEntnahme.ArtikelID
      AND KdArti.KundenID = _VOESTStudentenEntnahme.KundenID
      AND KdArti.Variante = _VOESTStudentenEntnahme.Variante;

    UPDATE _VOESTStudentenEntnahme SET TraeArtiID = TraeArti.ID
    FROM TraeArti
    WHERE TraeArti.TraegerID = _VOESTStudentenEntnahme.TraegerID
      AND TraeArti.KdArtiID = _VOESTStudentenEntnahme.KdArtiID
      AND TraeArti.ArtGroeID = _VOESTStudentenEntnahme.ArtGroeID;
  
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

DECLARE @MapTable TABLE (
  EinzTeilID int,
  EinzHistID int
);

DECLARE @curdatetime datetime2 = GETDATE();
/* Ausgabe in aktueller Woche */
/* DECLARE @newindienst varchar(7) = (SELECT [Week].Woche FROM [Week] WHERE CAST(DATEADD(week, 1, GETDATE()) AS date) BETWEEN [Week].VonDat AND [Week].BisDat);
DECLARE @newindienstdat date = (SELECT [Week].VonDat FROM [Week] WHERE CAST(DATEADD(week, 1, GETDATE()) AS date) BETWEEN [Week].VonDat AND [Week].BisDat); */
/* Ausgabe letzte Woche */
DECLARE @newindienst varchar(7) = (SELECT [Week].Woche FROM [Week] WHERE CAST(GETDATE() AS date) BETWEEN [Week].VonDat AND [Week].BisDat);
DECLARE @newindienstdat date = (SELECT [Week].VonDat FROM [Week] WHERE CAST(GETDATE() AS date) BETWEEN [Week].VonDat AND [Week].BisDat);
DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');
DECLARE @msg nvarchar(max);

BEGIN TRY
  BEGIN TRANSACTION;
  
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ Nicht vorhandene Trägerartikel anlegen                                                                                    ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    INSERT INTO TraeArti (VsaID, TraegerID, ArtGroeID, KdArtiID, AnlageUserID_, UserID_)
    SELECT DISTINCT _VOESTStudentenEntnahme.VsaID, _VOESTStudentenEntnahme.TraegerID, _VOESTStudentenEntnahme.ArtGroeID, _VOESTStudentenEntnahme.KdArtiID , @userid, @userid
    FROM _VOESTStudentenEntnahme
    WHERE _VOESTStudentenEntnahme.TraeArtiID IS NULL
      AND _VOESTStudentenEntnahme.VsaID IS NOT NULL
      AND _VOESTStudentenEntnahme.TraegerID IS NOT NULL
      AND _VOESTStudentenEntnahme.ArtGroeID IS NOT NULL
      AND _VOESTStudentenEntnahme.KdArtiID IS NOT NULL;

    UPDATE _VOESTStudentenEntnahme SET TraeArtiID = TraeArti.ID
    FROM TraeArti
    WHERE TraeArti.TraegerID = _VOESTStudentenEntnahme.TraegerID
      AND TraeArti.KdArtiID = _VOESTStudentenEntnahme.KdArtiID
      AND TraeArti.ArtGroeID = _VOESTStudentenEntnahme.ArtGroeID;

    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ Neuen EinzHist-Eintrag erstellen und in Mapping-Table eintragen                                                           ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    INSERT INTO EinzHist (EinzTeilID, Barcode, RentomatChip, SecondaryCode, UebernahmeCode, EinzHistTyp, [Status], EinzHistVon, KundenID, VsaID, TraegerID, TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, Eingang1, Eingang2, Eingang3, Ausgang1, Ausgang2, Ausgang3, Entnommen, EinsatzGrund, PatchDatum, Indienst, IndienstDat, RuecklaufK, AnzRepair, LagerArtID, EntnPoID, RestwertInfo, StartAuftragID, LastLsPoID, FirstLsPoID, UserID_, AnlageUserID_)
    OUTPUT inserted.EinzTeilID, inserted.ID
    INTO @MapTable (EinzTeilID, EinzHistID)
    SELECT EinzHist.EinzTeilID, EinzHist.Barcode, EinzHist.RentomatChip, EinzHist.SecondaryCode, EinzHist.UebernahmeCode, CAST(1 AS int) AS EinzHistTyp, EinzHist.[Status], @curdatetime AS EinzHistVon, _VOESTStudentenEntnahme.KundenID, _VOESTStudentenEntnahme.VsaID, _VOESTStudentenEntnahme.TraegerID, _VOESTStudentenEntnahme.TraeArtiID, _VOESTStudentenEntnahme.KdArtiID, _VOESTStudentenEntnahme.ArtikelID, _VOESTStudentenEntnahme.ArtGroeID, EinzHist.Eingang1, EinzHist.Eingang2, EinzHist.Eingang3, EinzHist.Ausgang1, EinzHist.Ausgang2, EinzHist.Ausgang3, EinzHist.Entnommen, EinzHist.EinsatzGrund, EinzHist.PatchDatum, @newindienst AS Indienst, @newindienstdat AS IndienstDat, EinzHist.RuecklaufK, EinzHist.AnzRepair, EinzHist.LagerartID, EinzHist.EntnPoID, EinzHist.RestwertInfo, EinzHist.StartAuftragID, EinzHist.LastLsPoID, EinzHist.FirstLsPoID, @userid AS UserID_, @userid AS AnlageUserID_
    FROM _VOESTStudentenEntnahme
    JOIN EinzHist ON _VOESTStudentenEntnahme.Barcode = EinzHist.Barcode
    WHERE EinzHist.ID = (SELECT EinzTeil.CurrEinzHistID FROM EinzTeil WHERE EinzTeil.ID = EinzHist.EinzTeilID)
      AND _VOESTStudentenEntnahme.EinzHistID IS NOT NULL
      AND _VOESTStudentenEntnahme.TraeArtiID IS NOT NULL;

    SELECT @msg = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss', N'de-AT') + N': Neuen EinzHist-Eintrag eingefügt';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ Alten Umlauf-Datensatz anpassen                                                                                           ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    UPDATE EinzHist SET EinzHistBis = @curdatetime, Abmeldung = @newindienst, AbmeldDat = @newindienstdat, Ausdienst = @newindienst, AusdienstDat = @newindienstdat, AusdienstGrund = N'Q', UserID_ = @userid
    FROM _VOESTStudentenEntnahme
    WHERE _VOESTStudentenEntnahme.EinzHistID = EinzHist.ID;

    SELECT @msg = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss', N'de-AT') + N': Alten EinzHist-Eintrage aktualisiert';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ EinzTeil-Datensatz anpassen                                                                                               ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    UPDATE EinzTeil SET CurrEinzHistID = [@MapTable].EinzHistID, UserID_ = @userid
    FROM _VOESTStudentenEntnahme
    JOIN @MapTable ON _VOESTStudentenEntnahme.EinzTeilID = [@MapTable].EinzTeilID
    WHERE _VOESTStudentenEntnahme.EinzTeilID = EinzTeil.ID

    SELECT @msg = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss', N'de-AT') + N': EinzTeil-Datensatz angepasst';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ Trägerartikel-Mengen anpassen                                                                                             ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    UPDATE TraeArti SET Menge = (SELECT COUNT(EinzHist.ID) FROM EinzHist WHERE EinzHist.TraeArtiID = TraeArti.ID AND EinzHist.ID = (SELECT EinzTeil.CurrEinzHistID FROM EinzTeil WHERE EinzTeil.ID = EinzHist.EinzTeilID))
    WHERE TraeArti.ID IN (SELECT TraeArtiID FROM _VOESTStudentenEntnahme);

    SELECT @msg = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss', N'de-AT') + N': Trägerartikel-Mengen angepasst';
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

GO

SELECT *
FROM _VOESTStudentenEntnahme
WHERE EinzHistID IS NULL OR TraegerID IS NULL OR TraeArtiID IS NULL;

GO

SELECT Barcode
FROM _VOESTStudentenEntnahme
WHERE EinzHistID IS NOT NULL
  AND TraegerID IS NOT NULL
  AND TraeArtiID IS NOT NULL
  AND KdArtiID IS NOT NULL
  AND VsaID IS NOT NULL
  AND ArtGroeID IS NOT NULL
  AND KdArtiID IS NOT NULL;

GO