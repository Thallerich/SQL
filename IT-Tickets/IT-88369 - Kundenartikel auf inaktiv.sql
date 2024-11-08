SET NOCOUNT, XACT_ABORT ON;
GO

DECLARE @KdArti TABLE (
  KdArtiID int
);

DECLARE @msg nvarchar(max);
DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

INSERT INTO @KdArti (KdArtiID)
SELECT KdArti.ID AS KdArtiID
FROM KdArti WITH (UPDLOCK)
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Salesianer.dbo._IT88369 ON Kunden.KdNr = _IT88369.KdNr AND Artikel.ArtikelNr = _IT88369.ArtikelNr
WHERE KdArti.[Status] != N'I';

SELECT @msg = FORMAT(@@ROWCOUNT, N'N0') + N' customer articles selected for update to inactive state.';
RAISERROR(@msg, 0, 1) WITH NOWAIT;

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE KdArti SET [Status] = N'I', UserID_ = @userid
    WHERE ID IN (SELECT KdArtiID FROM @KdArti);

    SELECT @msg = FORMAT(@@ROWCOUNT, N'N0') + N' customer articles set to inactive state.';
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