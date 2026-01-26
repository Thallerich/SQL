/*
ALTER TABLE _SortmasterTeile ADD EinzTeilID int, EinzHistID int;
*/

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');
DECLARE @ETmap TABLE (ID int, Barcode varchar(33));
DECLARE @EHmap TABLE (ID int, Barcode varchar(33));

BEGIN TRY
  BEGIN TRANSACTION;

    UPDATE EinzTeil SET Code2 = NULL WHERE Code2 IN (SELECT Code2 COLLATE Latin1_General_CS_AS FROM _SortmasterTeile);

    INSERT INTO EinzTeil (Code, Code2, [Status], ArtikelID, ArtGroeID, VsaID, ErstDatum, AnlageUserID_, UserID_)
    OUTPUT inserted.ID, inserted.Code
    INTO @ETmap (ID, Barcode)
    SELECT _SortmasterTeile.Code, _SortmasterTeile.Code2, _SortmasterTeile.[Status], _SortmasterTeile.ArtikelID, _SortmasterTeile.ArtGroeID, _SortmasterTeile.VsaID, CAST(GETDATE() AS date) AS Erstdatum, @userid AS AnlageUserID_, @userid AS UserID_
    FROM _SortmasterTeile
    WHERE NOT EXISTS (
      SELECT *
      FROM EinzTeil
      WHERE EinzTeil.Code = _SortmasterTeile.Code COLLATE Latin1_General_CS_AS
    );

    UPDATE _SortmasterTeile SET EinzTeilID = [@ETmap].ID
    FROM @ETmap
    WHERE [@ETmap].Barcode = _SortmasterTeile.Code;

    INSERT INTO TraeArti (VsaID, TraegerID, ArtGroeID, KdArtiID, AnlageUserID_, UserID_)
    SELECT DISTINCT _SortmasterTeile.VsaID, Traeger.ID AS TraegerID, _SortmasterTeile.ArtGroeID, KdArti.ID AS KdArtiID, @userid AS AnlageUserID_, @userid AS UserID_
    FROM _SortmasterTeile
    JOIN Traeger ON Traeger.ID = 9539549
    JOIN Vsa ON _SortmasterTeile.VsaID = Vsa.ID
    JOIN KdArti ON KdArti.KundenID = Vsa.KundenID AND KdArti.ArtikelID = _SortmasterTeile.ArtikelID
    WHERE _SortmasterTeile.EinzHistID IS NULL
      AND NOT EXISTS (
        SELECT TraeArti.*
        FROM TraeArti
        WHERE TraeArti.TraegerID = Traeger.ID
          AND TraeArti.ArtGroeID = _SortmasterTeile.ArtGroeID
          AND TraeArti.KdArtiID = KdArti.ID
      );

    INSERT INTO EinzHist (EinzTeilID, Barcode, RentomatChip, [Status], EinzHistVon, KundenID, VsaID, TraegerID, TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, Entnommen, EinsatzGrund, PatchDatum, AnlageUserID_, UserID_)
    OUTPUT inserted.ID, inserted.Barcode
    INTO @EHmap (ID, Barcode)
    SELECT _SortmasterTeile.EinzTeilID, _SortmasterTeile.Code AS Barcode, _SortmasterTeile.Code2 AS RentomatChip, 'Q' AS [Status], GETDATE() AS EinzHistVon, Vsa.KundenID, Vsa.ID AS VsaID, Traeger.ID AS TraegerID, TraeArti.ID AS TraeArtiID, KdArti.ID AS KdArtiID, _SortmasterTeile.ArtikelID, _SortmasterTeile.ArtGroeID, CAST(1 AS bit) AS Entnommen, '2' AS EinsatzGrund, CAST(GETDATE() AS date) AS Patchdatum, @userid AS AnlageUserID_, @userid AS UserID_
    FROM _SortmasterTeile
    JOIN Vsa ON _SortmasterTeile.VsaID = Vsa.ID
    JOIN Traeger ON Traeger.ID = 9539549
    JOIN KdArti ON KdArti.KundenID = Vsa.KundenID AND KdArti.ArtikelID = _SortmasterTeile.ArtikelID
    JOIN TraeArti ON TraeArti.TraegerID = Traeger.ID AND TraeArti.ArtGroeID = _SortmasterTeile.ArtGroeID AND TraeArti.KdArtiID = KdArti.ID
    WHERE _SortmasterTeile.EinzTeilID IS NOT NULL
      AND _SortmasterTeile.EinzHistID IS NULL;

    UPDATE _SortmasterTeile SET EinzHistID = [@EHmap].ID
    FROM @EHmap
    WHERE [@EHmap].Barcode = _SortmasterTeile.Code;

    UPDATE EinzTeil SET CurrEinzHistID = _SortmasterTeile.EinzHistID, UserID_ = @userid
    FROM _SortmasterTeile
    WHERE _SortmasterTeile.EinzTeilID = EinzTeil.ID
      AND _SortmasterTeile.EinzHistID > 0;
  
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