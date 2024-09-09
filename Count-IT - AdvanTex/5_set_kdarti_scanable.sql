SET XACT_ABORT ON;
SET NOCOUNT ON;
GO

DROP TABLE IF EXISTS #KdArti;
GO

DECLARE @kdarticount int;
DECLARE @notifymsg nvarchar(max);

SELECT KdArti.ID
INTO _KdArti_OptionalBC_20240909
FROM KdArti
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
WHERE Artikel.ArtGruID IN (
    SELECT ArtGru.ID
    FROM ArtGru
    JOIN Mitarbei ON ArtGru.UserID_ = Mitarbei.ID
    WHERE ArtGru.BereichID = (SELECT ID FROM Bereich WHERE Bereich = N'FW')
      AND ArtGru.OptionalBarcodiert = 0
      AND ArtGru.ZwingendBarcodiert = 0
  )
  AND EXISTS (
    SELECT VsaAnf.*
    FROM VsaAnf
    JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
    JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = KdBer.BereichID
    WHERE VsaAnf.KdArtiID = KdArti.ID
      AND StandBer.ProduktionID = (SELECT ID FROM Standort WHERE Bez = N'Produktion GP Enns')
  )
  AND KdArti.ArtiOptionalBarcodiert = 0
  AND KdArti.ArtiZwingendBarcodiert = 0;

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE KdArti SET ArtiOptionalBarcodiert = 1 WHERE ID IN (SELECT ID FROM _KdArti_OptionalBC_20240909);
    SET @kdarticount = @@ROWCOUNT;

    SET @notifymsg = FORMAT(@kdarticount, N'N') + N' Kundenartikel als optional scanbar definiert!'
    RAISERROR(@notifymsg, 0, 1) WITH NOWAIT;
  
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