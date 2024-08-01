/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Kundenartikel-Prüfung                                                                                                     ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT DISTINCT _IT85072.ArtikelNr
FROM _IT85072
WHERE NOT EXISTS (
  SELECT KdArti.*
  FROM KdArti
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN Kunden ON KdArti.KundenID = Kunden.ID
  WHERE Artikel.ArtikelNr = _IT85072.ArtikelNr
    AND Kunden.KdNr = _IT85072.KdNr
    AND KdArti.Variante = N'-'
);

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ vorhandene Teile verfälschen                                                                                              ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @CodeExists TABLE (Code varchar(33) COLLATE Latin1_General_CS_AS);

INSERT INTO @CodeExists (Code)
SELECT Code
FROM _IT85072
WHERE EXISTS (
  SELECT EinzTeil.*
  FROM EinzTeil
  WHERE EinzTeil.Code = _IT85072.Code
)
OR EXISTS (
  SELECT EinzTeil.*
  FROM EinzTeil
  WHERE EinzTeil.Code2 = _IT85072.Code
)
OR EXISTS (
  SELECT EinzTeil.*
  FROM EinzTeil
  WHERE EinzTeil.Code3 = _IT85072.Code
)
OR EXISTS (
  SELECT EinzTeil.*
  FROM EinzTeil
  WHERE EinzTeil.Code4 = _IT85072.Code
);

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE EinzTeil SET Code = Code + N'*BHS'
    WHERE EinzTeil.Code IN (SELECT Code FROM @CodeExists);

    UPDATE EinzTeil SET Code2 = Code2 + N'*BHS'
    WHERE EinzTeil.Code2 IN (SELECT Code FROM @CodeExists);

    UPDATE EinzTeil SET Code3 = Code3 + N'*BHS'
    WHERE EinzTeil.Code3 IN (SELECT Code FROM @CodeExists);

    UPDATE EinzTeil SET Code4 = Code4 + N'*BHS'
    WHERE EinzTeil.Code4 IN (SELECT Code FROM @CodeExists);

    UPDATE EinzHist SET Barcode = Barcode + N'*BHS'
    WHERE EinzHist.Barcode IN (SELECT Code FROM @CodeExists)
      AND EinzHist.ID = (SELECT EinzTeil.CurrEinzHistID FROM EinzTeil WHERE EinzTeil.ID = EinzHist.EinzTeilID);

    UPDATE EinzHist SET RentomatChip = RentomatChip + N'*BHS'
    WHERE EinzHist.RentomatChip IN (SELECT Code FROM @CodeExists)
      AND EinzHist.ID = (SELECT EinzTeil.CurrEinzHistID FROM EinzTeil WHERE EinzTeil.ID = EinzHist.EinzTeilID);

    UPDATE EinzHist SET SecondaryCode = SecondaryCode + N'*BHS'
    WHERE EinzHist.SecondaryCode IN (SELECT Code FROM @CodeExists)
      AND EinzHist.ID = (SELECT EinzTeil.CurrEinzHistID FROM EinzTeil WHERE EinzTeil.ID = EinzHist.EinzTeilID);

    UPDATE EinzHist SET UebernahmeCode = UebernahmeCode + N'*BHS'
    WHERE EinzHist.UebernahmeCode IN (SELECT Code FROM @CodeExists)
      AND EinzHist.ID = (SELECT EinzTeil.CurrEinzHistID FROM EinzTeil WHERE EinzTeil.ID = EinzHist.EinzTeilID);
  
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

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Neue Teile anlegen                                                                                                        ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');
DECLARE @traegerid int = 10005707;

DECLARE @ETmap TABLE (ID int, Barcode varchar(33) COLLATE Latin1_General_CS_AS);
DECLARE @EHmap TABLE (ID int, Barcode varchar(33) COLLATE Latin1_General_CS_AS);

BEGIN TRY
  BEGIN TRANSACTION;

    INSERT INTO TraeArti (VsaID, TraegerID, ArtGroeID, KdArtiID, AnlageUserID_, UserID_)
    SELECT DISTINCT Traeger.VsaID, ImportTraeger.TraegerID, ArtGroe.ID AS ArtGroeID, KdArti.ID AS KdArtiID, @userid, @userid
    FROM _IT85072
    CROSS JOIN (SELECT @traegerid AS TraegerID) AS ImportTraeger
    JOIN Traeger ON ImportTraeger.TraegerID = Traeger.ID
    JOIN Artikel ON _IT85072.ArtikelNr = Artikel.ArtikelNr
    JOIN Kunden ON _IT85072.KdNr = Kunden.KdNr
    JOIN KdArti ON KdArti.ArtikelID = Artikel.ID AND KdArti.KundenID = Kunden.ID AND KdArti.Variante = N'-'
    JOIN ArtGroe ON ArtGroe.ArtikelID = Artikel.ID AND ArtGroe.Groesse = _IT85072.Größe;
  
    INSERT INTO EinzTeil (Code, [Status], ArtikelID, ArtGroeID, ZielNrID, LastActionsID, LastScanTime, EkPreis, EkGrundAkt, ErstDatum, ErstWoche, RuecklaufG, AnlageUserID_, UserID_)
    OUTPUT inserted.ID, inserted.Code
    INTO @ETmap (ID, Barcode)
    SELECT _IT85072.Code, N'A' AS [Status], Artikel.ID AS ArtikelID, ArtGroe.ID AS ArtGroeID, 1 AS ZielNrID, 1 AS LastActionsID, GETDATE() AS LastScanTime, ArtGroe.EKPreis, ArtGroe.EKPreis AS EkGrundAkt, _IT85072.ErstDatum, [Week].Woche AS ErstWoche, _IT85072.Wäschen AS RuecklaufG, @userid AS AnlageUserID_, @userid AS UserID_
    FROM _IT85072
    JOIN Artikel ON _IT85072.ArtikelNr = Artikel.ArtikelNr
    JOIN ArtGroe ON ArtGroe.ArtikelID = Artikel.ID AND ArtGroe.Groesse = _IT85072.Größe
    JOIN [Week] ON _IT85072.ErstDatum BETWEEN [Week].VonDat AND [Week].BisDat
    WHERE NOT EXISTS (
      SELECT EinzTeil.*
      FROM EinzTeil
      WHERE EinzTeil.Code = _IT85072.Code
    );

    UPDATE _IT85072 SET EinzTeilID = [@ETmap].ID
    FROM @ETmap
    WHERE [@ETmap].Barcode = _IT85072.Code;

    INSERT INTO EinzHist (EinzTeilID, Barcode, [Status], EinzHistVon, KundenID, VsaID, TraegerID, TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, Entnommen, EinsatzGrund, PatchDatum, Eingang1, Ausgang1, RuecklaufK, AnlageUserID_, UserID_)
    OUTPUT inserted.ID, inserted.Barcode
    INTO @EHmap (ID, Barcode)
    SELECT _IT85072.EinzTeilID, _IT85072.Code, 'Q' AS [Status], GETDATE() AS EinzHistVon, Vsa.KundenID AS KundenID, Vsa.ID AS VsaID, Traeger.ID AS TraegerID, TraeArti.ID AS TraeArtiID, KdArti.ID AS KdArtiID, Artikel.ID AS ArtikelID, ArtGroe.ID AS ArtGroeID, CAST(1 AS bit) AS Entnommen, '2' AS EinsatzGrund, _IT85072.ErstDatum AS Patchdatum, _IT85072.Eingang1, _IT85072.Ausgang1, _IT85072.Wäschen AS RuecklaufK, @userid AS AnlageUserID_, @userid AS UserID_
    FROM _IT85072
    CROSS JOIN (SELECT @traegerid AS TraegerID) AS ImportTraeger
    JOIN Traeger ON ImportTraeger.TraegerID = Traeger.ID
    JOIN Vsa ON Traeger.VsaID = Vsa.ID
    JOIN Artikel ON Artikel.ArtikelNr = _IT85072.ArtikelNr
    JOIN KdArti ON KdArti.KundenID = Vsa.KundenID AND KdArti.ArtikelID = Artikel.ID AND KdArti.Variante = '-'
    JOIN ArtGroe ON ArtGroe.ArtikelID = Artikel.ID AND ArtGroe.Groesse = _IT85072.Größe
    JOIN TraeArti ON TraeArti.TraegerID = Traeger.ID AND TraeArti.ArtGroeID = ArtGroe.ID AND TraeArti.KdArtiID = KdArti.ID
    WHERE _IT85072.EinzTeilID > 0;

    UPDATE _IT85072 SET EinzHistID = [@EHmap].ID
    FROM @EHmap
    WHERE [@EHmap].Barcode = _IT85072.Code;

    UPDATE EinzTeil SET CurrEinzHistID = _IT85072.EinzHistID
    FROM _IT85072
    WHERE _IT85072.EinzTeilID = EinzTeil.ID
      AND _IT85072.EinzHistID > 0;
  
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