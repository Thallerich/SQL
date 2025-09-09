DROP TABLE IF EXISTS #NsEmblHinw;

SELECT Artikel.ID, Artikel.ArtiTypeID, COALESCE(ArtiNS.HinwTextID, ArtiEmb.HinwTextID) AS HinwTextID
INTO #NsEmblHinw
FROM Artikel
LEFT JOIN ArtiNS ON ArtiNS.ArtikelID = Artikel.ID
LEFT JOIN ArtiEmb ON ArtiEmb.ArtikelID = Artikel.ID
WHERE Artikel.ArtiTypeID IN (2, 3)
  AND COALESCE(ArtiNS.HinwTextID, ArtiEmb.HinwTextID) = -1;

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE ArtiNS SET HinwTextID = 18
    WHERE ArtiNS.ArtikelID IN (SELECT ID FROM #NsEmblHinw WHERE ArtiTypeID = 2)
      AND ArtiNS.HinwTextID = -1;

    UPDATE ArtiEmb SET HinwTextID = 1000530
    WHERE ArtiEmb.ArtikelID IN (SELECT ID FROM #NsEmblHinw WHERE ArtiTypeID = 3)
      AND ArtiEmb.HinwTextID = -1;

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