SET NOCOUNT ON;
SET XACT_ABORT ON;

GO

DECLARE @NewSchrankKdArtiID int, @KundenID int, @userid int;
DECLARE @msg nvarchar(max);

SELECT @userid = Mitarbei.ID FROM Mitarbei WHERE Mitarbei.UserName = UPPER(REPLACE(USER_NAME(), N'SAL\', N''));
SELECT @KundenID = Kunden.ID FROM Kunden WHERE Kunden.KdNr = 10007589;

SELECT @NewSchrankKdArtiID = KdArti.ID
FROM KdArti
WHERE KdArti.KundenID = @KundenID
  AND KdArti.ArtikelID = (SELECT Artikel.ID FROM Artikel WHERE Artikel.ArtikelNr = 'HKUND')
  AND KdArti.Variante = N'A';

IF @NewSchrankKdArtiID IS NOT NULL AND @userid IS NOT NULL
BEGIN
  BEGIN TRY
    BEGIN TRANSACTION;
    
      UPDATE Schrank SET KdArtiID = @NewSchrankKdArtiID, UserID_ = @userid
      WHERE Schrank.VsaID = (
          SELECT Vsa.ID
          FROM Vsa
          WHERE Vsa.KundenID = @KundenID
            AND Vsa.VsaNr = 3
        )
        AND Schrank.KdArtiID != @NewSchrankKdArtiID;

      SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - Schrank.KdArtiID wurde bei ' + FORMAT(@@ROWCOUNT, N'N0') + ' Datensätzen geändert. KdArtiID: ' + CAST(@NewSchrankKdArtiID AS nvarchar(10)) + N', UserID: ' + CAST(@userid AS nvarchar(10));
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
END
ELSE
BEGIN
  SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - Fehler: KdArtiID oder UserID konnte nicht ermittelt werden.';
  RAISERROR(@msg, 0, 1) WITH NOWAIT;
END;

GO