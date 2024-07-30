SET NOCOUNT ON;

DECLARE @kdnr int = 10001901;
DECLARE @sourcevsanr int = 4;
DECLARE @destinationvsanr int = 18;

DECLARE @Article TABLE (
  ArticleNr nvarchar(15) COLLATE Latin1_General_CS_AS,
  ArticleID int DEFAULT -1
);

INSERT INTO @Article (ArticleNr)
VALUES ('41001983514'), ('41001983512'), ('41001983507'), ('41001983513'), ('41001983515'), ('41001983511'), ('41001983510'), ('41001983509');

DECLARE @sourcevsaid int, @destinationvsaid int, @severity int;
DECLARE @state smallint;
DECLARE @message varchar(max);

SELECT @sourcevsaid = Vsa.ID
FROM Vsa
WHERE Vsa.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = @kdnr)
  AND Vsa.VsaNr = @sourcevsanr;

SELECT @destinationvsaid = Vsa.ID
FROM Vsa
WHERE Vsa.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = @kdnr)
  AND Vsa.VsaNr = @destinationvsanr;

IF EXISTS (SELECT * FROM @Article)
BEGIN
  UPDATE @Article SET ArticleID = Artikel.ID
  FROM Artikel
  WHERE [@Article].ArticleNr = Artikel.ArtikelNr;

  BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE EinzTeil SET VsaID = @destinationvsaid
    WHERE ID IN (
      SELECT EinzTeil.ID
      FROM EinzTeil
      WHERE EinzTeil.VsaID = @sourcevsaid
        AND EinzTeil.ArtikelID IN (SELECT ArticleID FROM @Article)
    );

    UPDATE VsaAnf SET BestandIst = 0
    WHERE VsaAnf.ID IN (
      SELECT VsaAnf.ID AS VsaAnfID /* , VsaAnf.Bestand, VsaAnf.BestandIst, Artikel.ArtikelNr, Artikel.ArtikelBez */
      FROM VsaAnf
      JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
      JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
      JOIN KdBer ON KdArti.KdBerID = KdBer.ID
      WHERE VsaAnf.VsaID = (SELECT Vsa.ID FROM Vsa WHERE Vsa.VsaNr = @sourcevsanr AND Vsa.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = @kdnr))
        AND NOT EXISTS (
          SELECT EinzTeil.*
          FROM EinzTeil
          WHERE EinzTeil.VsaID = VsaAnf.VsaID
            AND EinzTeil.ArtikelID = KdArti.ArtikelID
            AND EinzTeil.LastActionsID IN (2, 102, 120, 129, 130, 136, 137, 154)
            AND EinzTeil.LastErsatzFuerKdArtiID = -1
        )
        AND VsaAnf.BestandIst != 0
        AND (KdBer.IstBestandAnpass = 1 OR KdArti.IstBestandAnpass = 1)
    );
  
    COMMIT;
  END TRY
  BEGIN CATCH
    SET @message = ERROR_MESSAGE();
    SET @severity = ERROR_SEVERITY();
    SET @state = ERROR_STATE();
    
    IF XACT_STATE() != 0
      ROLLBACK TRANSACTION;
    
    RAISERROR(@message, @severity, @state) WITH NOWAIT;
  END CATCH;

  SET @message = N'Moved specific articles as specified!';
  RAISERROR(@message, 0, 1) WITH NOWAIT;
END
ELSE
BEGIN
  BEGIN TRY
    BEGIN TRANSACTION;
    
      UPDATE EinzTeil SET VsaID = @destinationvsaid
      WHERE ID IN (
        SELECT EinzTeil.ID
        FROM EinzTeil
        WHERE EinzTeil.VsaID = @sourcevsaid
      );

      UPDATE VsaAnf SET BestandIst = 0
      WHERE VsaAnf.ID IN (
        SELECT VsaAnf.ID AS VsaAnfID /* , VsaAnf.Bestand, VsaAnf.BestandIst, Artikel.ArtikelNr, Artikel.ArtikelBez */
        FROM VsaAnf
        JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
        JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
        JOIN KdBer ON KdArti.KdBerID = KdBer.ID
        WHERE VsaAnf.VsaID = (SELECT Vsa.ID FROM Vsa WHERE Vsa.VsaNr = @sourcevsanr AND Vsa.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = @kdnr))
          AND NOT EXISTS (
            SELECT EinzTeil.*
            FROM EinzTeil
            WHERE EinzTeil.VsaID = VsaAnf.VsaID
              AND EinzTeil.ArtikelID = KdArti.ArtikelID
              AND EinzTeil.LastActionsID IN (2, 102, 120, 129, 130, 136, 137, 154)
              AND EinzTeil.LastErsatzFuerKdArtiID = -1
          )
          AND VsaAnf.BestandIst != 0
          AND (KdBer.IstBestandAnpass = 1 OR KdArti.IstBestandAnpass = 1)
      );
    
    COMMIT;
  END TRY
  BEGIN CATCH
    SET @message = ERROR_MESSAGE();
    SET @severity = ERROR_SEVERITY();
    SET @state = ERROR_STATE();
    
    IF XACT_STATE() != 0
      ROLLBACK TRANSACTION;
    
    RAISERROR(@message, @severity, @state) WITH NOWAIT;
  END CATCH;

  SET @message = N'Moved ALL articles as specified!';
  RAISERROR(@message, 0, 1) WITH NOWAIT;
END;