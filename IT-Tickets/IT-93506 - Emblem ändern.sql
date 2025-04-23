SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

DROP TABLE IF EXISTS #NewKdArAppl;
GO

DECLARE @userid int = (SELECT Mitarbei.ID FROM Mitarbei WHERE Mitarbei.UserName = UPPER(REPLACE(ORIGINAL_LOGIN(), N'SAL\', N'')));
DECLARE @newapplkdartiid int = (SELECT KdArti.ID FROM KdArti WHERE KdArti.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = 10006791) AND KdArti.ArtikelID = (SELECT Artikel.ID FROM Artikel WHERE Artikel.ArtikelNr = 'BWTTFB'));

DECLARE @TraeApplOld TABLE (
  TraeApplID int
);

SELECT KdArAppl.ID, KdArAppl.KdArtiID, @newapplkdartiid AS ApplKdArtiID
INTO #NewKdArAppl
FROM KdArAppl
JOIN KdArti ON KdArAppl.KdArtiID = KdArti.ID
JOIN KdArti AS ApplKdArti ON KdArAppl.ApplKdArtiID = ApplKdArti.ID
WHERE KdArti.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = 10006791)
  AND ApplKdArti.ArtikelID = (SELECT Artikel.ID FROM Artikel WHERE Artikel.ArtikelNr = 'BWTTWB');

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE KdArAppl SET ApplKdArtiID = @newapplkdartiid, UserID_ = @userid
    WHERE ID IN (SELECT ID FROM #NewKdArAppl);

    UPDATE TraeAppl SET ApplKdArtiID = @newapplkdartiid, UserID_ = @userid
    OUTPUT deleted.ID INTO @TraeApplOld (TraeApplID)
    WHERE KdArApplID IN (SELECT ID FROM #NewKdArAppl);

    UPDATE TeilAppl SET TraeApplID = -1, UserID_ = @userid
    WHERE TraeApplID IN (SELECT TraeApplID FROM @TraeApplOld);
  
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