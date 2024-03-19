DECLARE @TeilAppl TABLE (
  ID int
);

DECLARE @TraeAppl TABLE (
  ID int
);

INSERT INTO @TeilAppl (ID)
SELECT TeilAppl.ID
FROM TeilAppl
JOIN EinzHist ON TeilAppl.EinzHistID = EinzHist.ID
JOIN EinzTeil ON EinzTeil.CurrEinzHistID = EinzHist.ID
WHERE EinzHist.KdArtiID IN (SELECT KdArti.ID FROM KdArti WHERE KdArti.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = 2523974))
  AND TeilAppl.ApplArtikelID != (SELECT Artikel.ID FROM Artikel WHERE Artikel.ArtikelNr = N'WAVIDB')
  AND EXISTS (SELECT ta.* FROM TeilAppl AS ta WHERE ta.EinzHistID = TeilAppl.EinzHistID AND ta.ApplArtikelID = (SELECT Artikel.ID FROM Artikel WHERE Artikel.ArtikelNr = N'WAVIDB'))
  AND TeilAppl.ArtiTypeID = 3
  AND TeilAppl.Bearbeitung != N'-'
  AND EinzHist.EinzHistTyp = 1;

INSERT INTO @TraeAppl (ID)
SELECT TraeAppl.ID
FROM TraeAppl
JOIN TraeArti ON TraeAppl.TraeArtiID = TraeArti.ID
JOIN KdArti ON TraeAppl.ApplKdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE TraeArti.KdArtiID IN (SELECT KdArti.ID FROM KdArti WHERE KdArti.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = 2523974))
  AND Artikel.ArtikelNr != N'WAVIDB'
  AND EXISTS (
    SELECT tr.*
    FROM TraeAppl AS tr
    JOIN KdArti ON tr.ApplKdArtiID = KdArti.ID
    JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
    WHERE tr.TraeArtiID = TraeAppl.TraeArtiID
      AND Artikel.ArtikelNr = N'WAVIDB'
  )
  AND TraeAppl.ArtiTypeID = 3;

BEGIN TRY
  BEGIN TRANSACTION;
  
    DELETE FROM TeilAppl WHERE ID IN (SELECT ID FROM @TeilAppl);

    UPDATE TeilAppl SET TraeApplID = -1 WHERE TraeApplID IN (SELECT ID FROM @TraeAppl);

    DELETE FROM TraeAppl WHERE ID IN (SELECT ID FROM @TraeAppl);
  
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