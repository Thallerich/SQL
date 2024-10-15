SET NOCOUNT ON;
SET XACT_ABORT ON;

GO

DROP TABLE IF EXISTS #ArtiFix;
GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ set parameters here                                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @istest bit = 0;                                                           /* if no data changes should be made set to 1 */
DECLARE @prod nvarchar(60) = N'Produktion GP Enns'; /* Produktion GP Enns */                  /* which production location to change */
DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');        /* user who makes the changes */

DECLARE @msg nvarchar(max);
DECLARE @errmsg nvarchar(max), @errseverity int, @errstate smallint;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ set parameters here                                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT DISTINCT Artikel.ID AS ArtikelID, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGru.ID AS ArtGruID, ArtGru.ArtGruBez AS Artikelgruppe, ArtGru.OptionalBarcodiert, ArtGru.ZwingendBarcodiert, Kunden.KdNr, Kunden.SuchCode AS Kunde, KdArti.ID AS KdArtiID, KdArti.ArtiOptionalBarcodiert, KdArti.ArtiZwingendBarcodiert
INTO #ArtiFix
FROM VsaAnf
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN StandBer ON KdBer.BereichID = StandBer.BereichID AND Vsa.StandKonID = StandBer.StandKonID
WHERE StandBer.ProduktionID = (SELECT Standort.ID FROM Standort WHERE Standort.Bez = @prod AND Standort.Produktion = 1)
  AND ArtGru.BereichID != (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = N'ST')
  AND (KdArti.ArtiOptionalBarcodiert = 0 OR (KdArti.ArtiOptionalBarcodiert = 1 AND (KdArti.ArtiZwingendBarcodiert = 1 OR ArtGru.OptionalBarcodiert = 1 OR ArtGru.ZwingendBarcodiert = 1)));

SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': ' + FORMAT(@@ROWCOUNT, N'N0') + N' customer articles need updating!';
RAISERROR(@msg, 0, 1) WITH NOWAIT;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ remove settings from artgru and apply them to kdarti instead                                                              ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

BEGIN TRY
  BEGIN TRANSACTION;
  
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ groups with forced scan                                                                                                   ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    WITH ArtGruZwingend AS (
      SELECT DISTINCT ArtGruID
      FROM #ArtiFix
      WHERE ZwingendBarcodiert = 1
    )
    UPDATE KdArti SET ArtiZwingendBarcodiert = 1, ArtiOptionalBarcodiert = 0, UserID_ = @userid
    FROM Artikel, ArtGruZwingend
    WHERE KdArti.ArtikelID = Artikel.ID
      AND Artikel.ArtGruID = ArtGruZwingend.ArtGruID
      AND (KdArti.ArtiZwingendBarcodiert = 0 OR KdArti.ArtiOptionalBarcodiert = 1);

    SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': ' + FORMAT(@@ROWCOUNT, N'N0') + N' customer articles had the article group setting ''forced scan'' applied!';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    UPDATE ArtGru SET ZwingendBarcodiert = 0, OptionalBarcodiert = 0, UserID_ = @userid
    WHERE ID IN (SELECT DISTINCT ArtGruID FROM #ArtiFix WHERE ZwingendBarcodiert = 1);

    SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': ' + FORMAT(@@ROWCOUNT, N'N0') + N' article groups had the forced scan setting removed!';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;
  
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ groups with optional scan                                                                                                 ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    WITH ArtGruZwingend AS (
      SELECT DISTINCT ArtGruID
      FROM #ArtiFix
      WHERE ZwingendBarcodiert = 0
        AND OptionalBarcodiert = 1
    )
    UPDATE KdArti SET ArtiZwingendBarcodiert = 0, ArtiOptionalBarcodiert = 1, UserID_ = @userid
    FROM Artikel, ArtGruZwingend
    WHERE KdArti.ArtikelID = Artikel.ID
      AND Artikel.ArtGruID = ArtGruZwingend.ArtGruID
      AND (KdArti.ArtiZwingendBarcodiert = 1 OR KdArti.ArtiOptionalBarcodiert = 0);

    SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': ' + FORMAT(@@ROWCOUNT, N'N0') + N' customer articles had the article group setting ''optional scan'' applied!';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    UPDATE ArtGru SET ZwingendBarcodiert = 0, OptionalBarcodiert = 0, UserID_ = @userid
    WHERE ID IN (SELECT DISTINCT ArtGruID FROM #ArtiFix WHERE ZwingendBarcodiert = 0 AND OptionalBarcodiert = 1);

    SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': ' + FORMAT(@@ROWCOUNT, N'N0') + N' article groups had the optional scan setting removed!';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;
  
  IF @istest = 1
    ROLLBACK
  ELSE
    COMMIT;
END TRY
BEGIN CATCH
  SELECT @errmsg = ERROR_MESSAGE(), @errseverity = ERROR_SEVERITY(), @errstate = ERROR_STATE();
  
  IF XACT_STATE() != 0
    ROLLBACK TRANSACTION;
  
  RAISERROR(@errmsg, @errseverity, @errstate) WITH NOWAIT;
END CATCH;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ set all customer articles for the specified production location as optional scan                                          ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE KdArti SET ArtiOptionalBarcodiert = 1, ArtiZwingendBarcodiert = 0, UserID_ = @userid
    WHERE ID IN (
        SELECT KdArtiID
        FROM #ArtiFix
      )
      AND (ArtiOptionalBarcodiert = 0 OR ArtiZwingendBarcodiert = 1);

    SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': ' + FORMAT(@@ROWCOUNT, N'N0') + N' customer articles for production location ' + @prod + N' have been changed to optional scan!';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;
  
  IF @istest = 1
    ROLLBACK
  ELSE
    COMMIT;
END TRY
BEGIN CATCH
  SELECT @errmsg = ERROR_MESSAGE(), @errseverity = ERROR_SEVERITY(), @errstate = ERROR_STATE();
  
  IF XACT_STATE() != 0
    ROLLBACK TRANSACTION;
  
  RAISERROR(@errmsg, @errseverity, @errstate) WITH NOWAIT;
END CATCH;

GO