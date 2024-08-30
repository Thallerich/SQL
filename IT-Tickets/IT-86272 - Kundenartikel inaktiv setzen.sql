SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

DECLARE @KdArtiInactive TABLE (
  KdArtiID int PRIMARY KEY CLUSTERED
);

DECLARE @msg nvarchar(max);

INSERT INTO @KdArtiInactive (KdArtiID)
SELECT KdArti.ID
FROM _IT86272
JOIN Kunden ON _IT86272.KdNr = Kunden.KdNr
JOIN Artikel ON _IT86272.ArtikelNr = Artikel.ArtikelNr
JOIN KdArti WITH (UPDLOCK) ON KdArti.ArtikelID = Artikel.ID AND KdArti.KundenID = Kunden.ID AND KdArti.Variante = _IT86272.Variante;

SET @msg = FORMAT(GETDATE(), N'yyy-MM-dd HH:mm:ss') + N': ' + FORMAT(@@ROWCOUNT, N'G', N'de-AT') + N' customer articles prepared for update to inactive state!';
RAISERROR(@msg, 0, 1) WITH NOWAIT;

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE KdArti SET [Status] = N'I'
    WHERE ID IN (SELECT KdArtiID FROM @KdArtiInactive)
      AND [Status] != N'I';

    SET @msg = FORMAT(GETDATE(), N'yyy-MM-dd HH:mm:ss') + N': ' + FORMAT(@@ROWCOUNT, N'G', N'de-AT') + N' customer articles have been set to inactive state!';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    UPDATE VsaAnf SET [Status] = N'I'
    WHERE KdArtiID IN (SELECT KdArtiID FROM @KdArtiInactive)
      AND [Status] != N'I'
      AND [Status] != N'E';
    
    SET @msg = FORMAT(GETDATE(), N'yyy-MM-dd HH:mm:ss') + N': ' + FORMAT(@@ROWCOUNT, N'G', N'de-AT') + N' order-able articles have been set to inactive state!';
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