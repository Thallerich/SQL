CREATE TABLE #TeilAppl (
  ID int PRIMARY KEY CLUSTERED,
  TraeApplID int,
  TraeArtiID int,
  ApplKdArtiID int
);

INSERT INTO #TeilAppl
SELECT TeilAppl.ID, TeilAppl.TraeApplID, EinzHist.TraeArtiID, TeilAppl.ApplKdArtiID
FROM TeilAppl
JOIN EinzHist ON TeilAppl.EinzHistID = EinzHist.ID
WHERE EinzHist.KdArtiID = 34912634
  AND TeilAppl.ApplArtikelID = (SELECT Artikel.ID FROM Artikel WHERE Artikel.ArtikelNr = N'DENZB');

BEGIN TRY
  BEGIN TRANSACTION;
  
    DELETE FROM TeilAppl WHERE ID IN (SELECT ID FROM #TeilAppl);

    DELETE FROM MsgTraeM WHERE TraeApplID IN (SELECT TraeApplID FROM #TeilAppl) AND TraeArtiID IN (SELECT TraeArtiID FROM #TeilAppl) AND TraeArtiID > 0;

    DELETE FROM TraeAppl WHERE ID IN (SELECT TraeApplID FROM #TeilAppl) AND TraeArtiID IN (SELECT TraeArtiID FROM #TeilAppl) AND TraeArtiID > 0;
    DELETE FROM TraeAppl WHERE ApplKdArtiID IN (SELECT ApplKdArtiID FROM #TeilAppl) AND NOT EXISTS (SELECT EinzHist.ID FROM EinzHist WHERE EinzHist.TraeArtiID = TraeAppl.TraeArtiID);
  
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

DROP TABLE #TeilAppl;