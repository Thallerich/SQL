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
      SELECT DISTINCT _IT78713.KdNr
      FROM _IT78713
    )
  )
);

SELECT KdNr,
  VsaNr,
  DENSE_RANK() OVER (ORDER BY Nachname, Vorname) + @maxexistingtraegernr Traeger,
  Vorname,
  Nachname,
  [Personalnummer ] AS PersNr,
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
FROM _IT78713
GROUP BY KdNr, VsaNr, Kst, Vorname, Nachname, [Personalnummer ], ArtikelNr, Groesse, Variante

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Prüfung auf bereits in AdvanTex vorhandene Barcodes, diese werden nicht importiert!                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT _IT78713.*
FROM _IT78713
WHERE EXISTS (
  SELECT EinzTeil.*
  FROM EinzTeil
  WHERE EinzTeil.Code = _IT78713.Barcode COLLATE Latin1_General_CS_AS
)
OR EXISTS (
  SELECT EinzTeil.*
  FROM EinzTeil
  WHERE EinzTeil.Code2 = _IT78713.Barcode COLLATE Latin1_General_CS_AS
)
OR EXISTS (
  SELECT EinzTeil.*
  FROM EinzTeil
  WHERE EinzTeil.Code3 = _IT78713.Barcode COLLATE Latin1_General_CS_AS
)
OR EXISTS (
  SELECT EinzTeil.*
  FROM EinzTeil
  WHERE EinzTeil.Code4 = _IT78713.Barcode COLLATE Latin1_General_CS_AS
);

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Import der Barcodes - Träger müssen hier bereits importiert worden sein!                                                  ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');
DECLARE @ETmap TABLE (ID int, Barcode varchar(33));
DECLARE @EHmap TABLE (ID int, Barcode varchar(33));

BEGIN TRY
  BEGIN TRANSACTION;
  
    INSERT INTO EinzTeil (Code, [Status], ArtikelID, ArtGroeID, ZielNrID, LastActionsID, LastScanTime, EkPreis, EkGrundAkt, AnlageUserID_, UserID_)
    OUTPUT inserted.ID, inserted.Code
    INTO @ETmap (ID, Barcode)
    SELECT _IT78713.Barcode, N'A' AS [Status], Artikel.ID AS ArtikelID, ArtGroe.ID AS ArtGroeID, 1 AS ZielNrID, 1 AS LastActionsID, GETDATE() AS LastScanTime, ArtGroe.EKPreis, ArtGroe.EKPreis AS EkGrundAkt, @userid AS AnlageUserID_, @userid AS UserID_
    FROM _IT78713
    JOIN Artikel ON _IT78713.ArtikelNr COLLATE Latin1_General_CS_AS = Artikel.ArtikelNr
    JOIN ArtGroe ON ArtGroe.ArtikelID = Artikel.ID AND ArtGroe.Groesse = _IT78713.Groesse COLLATE Latin1_General_CS_AS
    WHERE NOT EXISTS (
      SELECT EinzTeil.*
      FROM EinzTeil
      WHERE EinzTeil.Code = _IT78713.Barcode COLLATE Latin1_General_CS_AS
    );

    UPDATE _IT78713 SET EinzTeilID = [@ETmap].ID
    FROM @ETmap
    WHERE [@ETmap].Barcode = _IT78713.Barcode;

    INSERT INTO EinzHist (EinzTeilID, Barcode, [Status], EinzHistVon, KundenID, VsaID, TraegerID, TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, Entnommen, EinsatzGrund, PatchDatum, AnlageUserID_, UserID_)
    OUTPUT inserted.ID, inserted.Barcode
    INTO @EHmap (ID, Barcode)
    SELECT _IT78713.EinzTeilID, _IT78713.Barcode, 'M' AS [Status], GETDATE() AS EinzHistVon, Kunden.ID AS KundenID, Vsa.ID AS VsaID, Traeger.ID AS TraegerID, TraeArti.ID AS TraeArtiID, KdArti.ID AS KdArtiID, Artikel.ID AS ArtikelID, ArtGroe.ID AS ArtGroeID, CAST(1 AS bit) AS Entnommen, '2' AS EinsatzGrund, CAST(GETDATE() AS date) AS Patchdatum, @userid AS AnlageUserID_, @userid AS UserID_
    FROM _IT78713
    JOIN Kunden ON Kunden.KdNr = _IT78713.KdNr
    JOIN Vsa ON Vsa.KundenID = Kunden.ID AND Vsa.VsaNr = _IT78713.VsaNr
    JOIN Traeger ON Traeger.VsaID = Vsa.ID AND Traeger.Nachname = _IT78713.Nachname COLLATE Latin1_General_CS_AS AND Traeger.Vorname = _IT78713.Vorname COLLATE Latin1_General_CS_AS AND Traeger.PersNr = _IT78713.[Personalnummer ] COLLATE Latin1_General_CS_AS
    JOIN Artikel ON Artikel.ArtikelNr = _IT78713.ArtikelNr COLLATE Latin1_General_CS_AS
    JOIN KdArti ON KdArti.KundenID = Kunden.ID AND KdArti.ArtikelID = Artikel.ID AND KdArti.Variante = _IT78713.Variante COLLATE Latin1_General_CS_AS
    JOIN ArtGroe ON ArtGroe.ArtikelID = Artikel.ID AND ArtGroe.Groesse = _IT78713.Groesse COLLATE Latin1_General_CS_AS
    JOIN TraeArti ON TraeArti.TraegerID = Traeger.ID AND TraeArti.ArtGroeID = ArtGroe.ID AND TraeArti.KdArtiID = KdArti.ID
    WHERE _IT78713.EinzTeilID > 0;

    UPDATE _IT78713 SET EinzHistID = [@EHmap].ID
    FROM @EHmap
    WHERE [@EHmap].Barcode = _IT78713.Barcode;

    UPDATE EinzTeil SET CurrEinzHistID = _IT78713.EinzHistID
    FROM _IT78713
    WHERE _IT78713.EinzTeilID = EinzTeil.ID
      AND _IT78713.EinzHistID > 0;
  
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