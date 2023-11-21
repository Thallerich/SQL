DECLARE @kdnr int = 10001756;
DECLARE @sourcevsanr int = 1;
DECLARE @destinationvsanr int = 51;

DECLARE @sourcevsaid int, @destinationvsaid int;

SELECT @sourcevsaid = Vsa.ID
FROM Vsa
WHERE Vsa.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = @kdnr)
  AND Vsa.VsaNr = @sourcevsanr;

SELECT @destinationvsaid = Vsa.ID
FROM Vsa
WHERE Vsa.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = @kdnr)
  AND Vsa.VsaNr = @destinationvsanr;

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE EinzTeil SET VsaID = @destinationvsaid
    WHERE ID IN (
      SELECT EinzTeil.ID
      FROM EinzTeil
      JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
      WHERE EinzTeil.VsaID = @sourcevsaid
        AND (Artikel.BereichID = (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = N'FW') OR Artikel.ArtikelNr IN (N'54A7L', N'54A7XL'))
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
  DECLARE @Message varchar(MAX) = ERROR_MESSAGE();
  DECLARE @Severity int = ERROR_SEVERITY();
  DECLARE @State smallint = ERROR_STATE();
  
  IF XACT_STATE() != 0
    ROLLBACK TRANSACTION;
  
  RAISERROR(@Message, @Severity, @State) WITH NOWAIT;
END CATCH;