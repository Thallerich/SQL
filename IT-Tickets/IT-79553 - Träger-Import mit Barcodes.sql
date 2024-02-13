/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Import-Tabelle für Datenimport erstellen - Datenimport über Import-Wizard                                                 ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

CREATE TABLE [dbo].[_IT79553] (
  [KdNr] int NOT NULL,
  [VsaNr] int NOT NULL,
  [Kst] nvarchar(20) COLLATE Latin1_General_CS_AS,
  [Vorname] nvarchar(20) COLLATE Latin1_General_CS_AS,
  [Nachname] nvarchar(40) COLLATE Latin1_General_CS_AS,
  [Personalnummer] nvarchar(10) COLLATE Latin1_General_CS_AS,
  [ArtikelNr] nvarchar(15) COLLATE Latin1_General_CS_AS,
  [Groesse] nvarchar(12) COLLATE Latin1_General_CS_AS,
  [Barcode] varchar(33) COLLATE Latin1_General_CS_AS,
  [Variante] nvarchar(2) COLLATE Latin1_General_CS_AS,
  [Indienst] date,
  [ErstDatum] date,
  [AnzWäschen] int DEFAULT 0,
  [Schrank] nvarchar(15) COLLATE Latin1_General_CS_AS,
  [EinzTeilID] int,
  [EinzHistID] int
);

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Erstellen einer Anprobe-Liste für den Träger-Import über die AdvanTex-Funktionalität                                      ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @maxexistingtraegernr int;

SELECT @maxexistingtraegernr = ISNULL(MAX(TRY_CAST(Traeger.Traeger AS int)), 0)
FROM Traeger
WHERE Traeger.VsaID IN (
  SELECT Vsa.ID
  FROM Vsa
  WHERE Vsa.KundenID = (
    SELECT DISTINCT Kunden.ID
    FROM Kunden
    WHERE Kunden.KdNr = (
      SELECT DISTINCT Salesianer.dbo._IT79553.KdNr
      FROM Salesianer.dbo._IT79553
    )
  )
);

SELECT KdNr,
  VsaNr,
  DENSE_RANK() OVER (ORDER BY Nachname, Vorname, Personalnummer) + @maxexistingtraegernr Traeger,
  Vorname,
  Nachname,
  Personalnummer AS PersNr,
  KSt AS Kostenstelle,
  NULL AS Sortierschluessel,
  NULL AS Schrank,
  NULL AS Fach,
  0 AS Menge,
  ArtikelNr,
  NULL AS ArtikelBez,
  Variante,
  Groesse,
  0 AS Aufkauf,
  N'J' AS mitNS,
  N'J' AS mitEm,
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
  NULL AS Namensschild_Zeile_2,
  NULL AS Folge_ArtikelNr,
  NULL AS Folge_ArtikelBez,
  NULL AS Folge_Groesse,
  NULL AS Folge_Variante,
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
FROM Salesianer.dbo._IT79553
GROUP BY KdNr, VsaNr, Kst, Vorname, Nachname, Personalnummer, ArtikelNr, Groesse, Variante

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Prüfung auf bereits in AdvanTex vorhandene Barcodes, diese werden nicht importiert!                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Salesianer.dbo._IT79553.*
FROM Salesianer.dbo._IT79553
WHERE EXISTS (
  SELECT EinzTeil.*
  FROM EinzTeil
  WHERE EinzTeil.Code = Salesianer.dbo._IT79553.Barcode
)
OR EXISTS (
  SELECT EinzTeil.*
  FROM EinzTeil
  WHERE EinzTeil.Code2 = Salesianer.dbo._IT79553.Barcode
)
OR EXISTS (
  SELECT EinzTeil.*
  FROM EinzTeil
  WHERE EinzTeil.Code3 = Salesianer.dbo._IT79553.Barcode
)
OR EXISTS (
  SELECT EinzTeil.*
  FROM EinzTeil
  WHERE EinzTeil.Code4 = Salesianer.dbo._IT79553.Barcode
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
  
    INSERT INTO EinzTeil (Code, [Status], ArtikelID, ArtGroeID, ZielNrID, LastActionsID, LastScanTime, EkPreis, EkGrundAkt, AnlageUserID_, UserID_)
    OUTPUT inserted.ID, inserted.Code
    INTO @ETmap (ID, Barcode)
    SELECT Salesianer.dbo._IT79553.Barcode, N'A' AS [Status], Artikel.ID AS ArtikelID, ArtGroe.ID AS ArtGroeID, 1 AS ZielNrID, 1 AS LastActionsID, GETDATE() AS LastScanTime, ArtGroe.EKPreis, ArtGroe.EKPreis AS EkGrundAkt, @userid AS AnlageUserID_, @userid AS UserID_
    FROM Salesianer.dbo._IT79553
    JOIN Artikel ON Salesianer.dbo._IT79553.ArtikelNr = Artikel.ArtikelNr
    JOIN ArtGroe ON ArtGroe.ArtikelID = Artikel.ID AND ArtGroe.Groesse = Salesianer.dbo._IT79553.Groesse
    WHERE NOT EXISTS (
      SELECT EinzTeil.*
      FROM EinzTeil
      WHERE EinzTeil.Code = Salesianer.dbo._IT79553.Barcode
    );

    UPDATE Salesianer.dbo._IT79553 SET EinzTeilID = [@ETmap].ID
    FROM @ETmap
    WHERE [@ETmap].Barcode = Salesianer.dbo._IT79553.Barcode

    INSERT INTO EinzHist (EinzTeilID, Barcode, [Status], EinzHistVon, KundenID, VsaID, TraegerID, TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, Entnommen, EinsatzGrund, PatchDatum, AnlageUserID_, UserID_)
    OUTPUT inserted.ID, inserted.Barcode
    INTO @EHmap (ID, Barcode)
    SELECT Salesianer.dbo._IT79553.EinzTeilID, Salesianer.dbo._IT79553.Barcode, 'M' AS [Status], GETDATE() AS EinzHistVon, Kunden.ID AS KundenID, Vsa.ID AS VsaID, Traeger.ID AS TraegerID, TraeArti.ID AS TraeArtiID, KdArti.ID AS KdArtiID, Artikel.ID AS ArtikelID, ArtGroe.ID AS ArtGroeID, CAST(1 AS bit) AS Entnommen, '2' AS EinsatzGrund, CAST(GETDATE() AS date) AS Patchdatum, @userid AS AnlageUserID_, @userid AS UserID_
    FROM Salesianer.dbo._IT79553
    JOIN Kunden ON Kunden.KdNr = Salesianer.dbo._IT79553.KdNr
    JOIN Vsa ON Vsa.KundenID = Kunden.ID AND Vsa.VsaNr = Salesianer.dbo._IT79553.VsaNr
    JOIN Traeger ON Traeger.VsaID = Vsa.ID AND Traeger.Nachname = Salesianer.dbo._IT79553.Nachname AND Traeger.Vorname = Salesianer.dbo._IT79553.Vorname AND Traeger.PersNr = Salesianer.dbo._IT79553.Personalnummer
    JOIN Artikel ON Artikel.ArtikelNr = Salesianer.dbo._IT79553.ArtikelNr
    JOIN KdArti ON KdArti.KundenID = Kunden.ID AND KdArti.ArtikelID = Artikel.ID AND KdArti.Variante = Salesianer.dbo._IT79553.Variante
    JOIN ArtGroe ON ArtGroe.ArtikelID = Artikel.ID AND ArtGroe.Groesse = Salesianer.dbo._IT79553.Groesse
    JOIN TraeArti ON TraeArti.TraegerID = Traeger.ID AND TraeArti.ArtGroeID = ArtGroe.ID AND TraeArti.KdArtiID = KdArti.ID
    WHERE Salesianer.dbo._IT79553.EinzTeilID > 0;

    UPDATE Salesianer.dbo._IT79553 SET EinzHistID = [@EHmap].ID
    FROM @EHmap
    WHERE [@EHmap].Barcode = Salesianer.dbo._IT79553.Barcode

    UPDATE EinzTeil SET CurrEinzHistID = Salesianer.dbo._IT79553.EinzHistID
    FROM Salesianer.dbo._IT79553
    WHERE Salesianer.dbo._IT79553.EinzTeilID = EinzTeil.ID
      AND Salesianer.dbo._IT79553.EinzHistID > 0;
  
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