/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Import-Tabelle für Datenimport erstellen - Datenimport über Import-Wizard                                                 ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

CREATE TABLE [dbo].[_IT102308] (
  [KdNr] int NOT NULL,
  [VsaNr] int NOT NULL,
  [Traeger] varchar(8) COLLATE Latin1_General_CS_AS,
  [Kst] nvarchar(20) COLLATE Latin1_General_CS_AS,
  [Vorname] nvarchar(20) COLLATE Latin1_General_CS_AS,
  [Nachname] nvarchar(40) COLLATE Latin1_General_CS_AS,
  [Personalnummer] nvarchar(10) COLLATE Latin1_General_CS_AS,
  [ArtikelNr] nvarchar(15) COLLATE Latin1_General_CS_AS,
  [Groesse] nvarchar(12) COLLATE Latin1_General_CS_AS,
  [Barcode] varchar(33) COLLATE Latin1_General_CS_AS,
  [Variante] nvarchar(4) COLLATE Latin1_General_CS_AS,
  [Indienst] date,
  [ErstDatum] date,
  [AnzWäschen] int DEFAULT 0,
  [Schrank] nvarchar(15) COLLATE Latin1_General_CS_AS,
  [Fach] int,
  [mitNS] char(1) COLLATE Latin1_General_CS_AS,
  [mitEm] char(1) COLLATE Latin1_General_CS_AS,
  [Namensschild_Zeile_2] nvarchar(40) COLLATE Latin1_General_CS_AS,
  [Folge_ArtikelNr] nvarchar(15) COLLATE Latin1_General_CS_AS,
  [Folge_Groesse] nvarchar(12) COLLATE Latin1_General_CS_AS,
  [Folge_Variante] nvarchar(4) COLLATE Latin1_General_CS_AS,
  [EinzTeilID] int,
  [EinzHistID] int
);

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Erstellen einer Anprobe-Liste für den Träger-Import über die AdvanTex-Funktionalität                                      ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT _IT102308.KdNr,
  _IT102308.VsaNr,
  _IT102308.Traeger,
  _IT102308.Vorname,
  _IT102308.Nachname,
  _IT102308.Personalnummer AS PersNr,
  _IT102308.KSt AS Kostenstelle,
  NULL AS Sortierschluessel,
  _IT102308.Schrank,
  _IT102308.Fach,
  0 AS Menge,
  _IT102308.ArtikelNr,
  Artikel.ArtikelBez,
  _IT102308.Variante,
  _IT102308.Groesse,
  0 AS Aufkauf,
  _IT102308.mitNS,
  _IT102308.mitEm,
  NULL AS Titel,
  NULL AS Änderungsart1,
  NULL AS Änderungsmass1,
  NULL AS ÄnderungsPlatzierung1,
  NULL AS Änderungsart2,
  NULL AS Änderungsmass2,
  NULL AS ÄnderungsPlatzierung2,
  NULL AS Änderungsart3,
  NULL AS Änderungsmass3,
  NULL AS ÄnderungsPlatzierung3,
  _IT102308.Namensschild_Zeile_2,
  _IT102308.Folge_ArtikelNr,
  FolgeArtikel.ArtikelBez AS Folge_ArtikelBez,
  _IT102308.Folge_Groesse,
  _IT102308.Folge_Variante,
  NULL AS Folge_Änderungsart1,
  NULL AS Folge_Änderungsmass1,
  NULL AS Folge_ÄnderungsPlatzierung1,
  NULL AS Folge_Änderungsart2,
  NULL AS Folge_Änderungsmass2,
  NULL AS Folge_ÄnderungsPlatzierung2,
  NULL AS Folge_Änderungsart3,
  NULL AS Folge_Änderungsmass3,
  NULL AS Folge_ÄnderungsPlatzierung3,
  NULL AS Sonstiges,
  NULL AS Kommentare,
  NULL AS Abschluss
FROM Salesianer.dbo._IT102308
JOIN Artikel ON _IT102308.ArtikelNr = Artikel.ArtikelNr
LEFT JOIN Artikel AS FolgeArtikel ON _IT102308.Folge_ArtikelNr = FolgeArtikel.ArtikelNr
GROUP BY _IT102308.KdNr, _IT102308.VsaNr, _IT102308.Traeger, _IT102308.Vorname, _IT102308.Nachname, _IT102308.Personalnummer, _IT102308.Kst, _IT102308.Schrank, _IT102308.Fach, _IT102308.ArtikelNr, Artikel.ArtikelBez, _IT102308.Variante, _IT102308.Groesse, _IT102308.mitNS, _IT102308.mitEm, _IT102308.Namensschild_Zeile_2, _IT102308.Folge_ArtikelNr, FolgeArtikel.ArtikelBez, _IT102308.Folge_Groesse, _IT102308.Folge_Variante;

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Prüfung auf bereits in AdvanTex vorhandene Barcodes, diese werden nicht importiert!                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Salesianer.dbo._IT102308.*
FROM Salesianer.dbo._IT102308
WHERE EXISTS (
  SELECT EinzTeil.*
  FROM EinzTeil
  WHERE EinzTeil.Code = Salesianer.dbo._IT102308.Barcode
)
OR EXISTS (
  SELECT EinzTeil.*
  FROM EinzTeil
  WHERE EinzTeil.Code2 = Salesianer.dbo._IT102308.Barcode
)
OR EXISTS (
  SELECT EinzTeil.*
  FROM EinzTeil
  WHERE EinzTeil.Code3 = Salesianer.dbo._IT102308.Barcode
)
OR EXISTS (
  SELECT EinzTeil.*
  FROM EinzTeil
  WHERE EinzTeil.Code4 = Salesianer.dbo._IT102308.Barcode
);

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Import der Barcodes - Träger müssen hier bereits importiert worden sein!                                                  ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');
DECLARE @ETmap TABLE (ID int, Barcode varchar(33) COLLATE Latin1_General_CS_AS);
DECLARE @EHmap TABLE (ID int, Barcode varchar(33) COLLATE Latin1_General_CS_AS);

BEGIN TRY
  BEGIN TRANSACTION;
  
    INSERT INTO EinzTeil (Code, [Status], ArtikelID, ArtGroeID, ZielNrID, LastActionsID, LastScanTime, EkPreis, EkGrundAkt, ErstDatum, RuecklaufG, AnlageUserID_, UserID_)
    OUTPUT inserted.ID, inserted.Code
    INTO @ETmap (ID, Barcode)
    SELECT _IT102308.Barcode, N'A' AS [Status], Artikel.ID AS ArtikelID, ArtGroe.ID AS ArtGroeID, 1 AS ZielNrID, 1 AS LastActionsID, GETDATE() AS LastScanTime, ArtGroe.EKPreis, ArtGroe.EKPreis AS EkGrundAkt, _IT102308.ErstDatum, _IT102308.AnzWäschen AS RuecklaufG, @userid AS AnlageUserID_, @userid AS UserID_
    FROM Salesianer.dbo._IT102308
    JOIN Artikel ON _IT102308.ArtikelNr = Artikel.ArtikelNr
    JOIN ArtGroe ON ArtGroe.ArtikelID = Artikel.ID AND ArtGroe.Groesse = _IT102308.Groesse
    WHERE NOT EXISTS (
      SELECT EinzTeil.*
      FROM EinzTeil
      WHERE EinzTeil.Code = _IT102308.Barcode
    );

    UPDATE Salesianer.dbo._IT102308 SET EinzTeilID = [@ETmap].ID
    FROM @ETmap
    WHERE [@ETmap].Barcode = _IT102308.Barcode;

    INSERT INTO EinzHist (EinzTeilID, Barcode, [Status], EinzHistVon, KundenID, VsaID, TraegerID, TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, Entnommen, EinsatzGrund, PatchDatum, IndienstDat, Indienst, RuecklaufK, AnlageUserID_, UserID_)
    OUTPUT inserted.ID, inserted.Barcode
    INTO @EHmap (ID, Barcode)
    SELECT _IT102308.EinzTeilID, _IT102308.Barcode, 'M' AS [Status], GETDATE() AS EinzHistVon, Kunden.ID AS KundenID, Vsa.ID AS VsaID, Traeger.ID AS TraegerID, TraeArti.ID AS TraeArtiID, KdArti.ID AS KdArtiID, Artikel.ID AS ArtikelID, ArtGroe.ID AS ArtGroeID, CAST(1 AS bit) AS Entnommen, '2' AS EinsatzGrund, CAST(GETDATE() AS date) AS Patchdatum, _IT102308.Indienst AS IndienstDat, [Week].Woche AS Indienst, _IT102308.AnzWäschen AS RuecklaufK, @userid AS AnlageUserID_, @userid AS UserID_
    FROM Salesianer.dbo._IT102308
    JOIN Kunden ON Kunden.KdNr = _IT102308.KdNr
    JOIN Vsa ON Vsa.KundenID = Kunden.ID AND Vsa.VsaNr = _IT102308.VsaNr
    JOIN Traeger ON Traeger.VsaID = Vsa.ID AND Traeger.Traeger = _IT102308.Traeger
    JOIN Artikel ON Artikel.ArtikelNr = _IT102308.ArtikelNr
    JOIN KdArti ON KdArti.KundenID = Kunden.ID AND KdArti.ArtikelID = Artikel.ID AND KdArti.Variante = _IT102308.Variante
    JOIN ArtGroe ON ArtGroe.ArtikelID = Artikel.ID AND ArtGroe.Groesse = _IT102308.Groesse
    JOIN TraeArti ON TraeArti.TraegerID = Traeger.ID AND TraeArti.ArtGroeID = ArtGroe.ID AND TraeArti.KdArtiID = KdArti.ID
    JOIN [Week] ON _IT102308.Indienst BETWEEN [Week].VonDat AND [Week].BisDat
    WHERE _IT102308.EinzTeilID > 0;

    UPDATE Salesianer.dbo._IT102308 SET EinzHistID = [@EHmap].ID
    FROM @EHmap
    WHERE [@EHmap].Barcode = _IT102308.Barcode;

    UPDATE EinzTeil SET CurrEinzHistID = _IT102308.EinzHistID
    FROM Salesianer.dbo._IT102308
    WHERE _IT102308.EinzTeilID = EinzTeil.ID
      AND _IT102308.EinzHistID > 0;
  
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