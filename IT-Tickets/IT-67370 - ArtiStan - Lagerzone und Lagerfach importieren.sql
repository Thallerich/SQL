DROP TABLE IF EXISTS #FillArtiStan;

GO

SELECT Artikel.ID AS ArtikelID, Standort.ID AS StandortID, _IT67370.Lagerzone, _IT67370.Lagerfach
INTO #FillArtiStan
FROM _IT67370
JOIN Artikel ON _IT67370.ArtikelNr = Artikel.ArtikelNr
CROSS JOIN Standort
WHERE Standort.SuchCode = N'INZ'
  AND _IT67370.Lagerzone IS NOT NULL
  AND _IT67370.Lagerfach IS NOT NULL

GO

DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

BEGIN TRY
  BEGIN TRANSACTION;

    UPDATE ArtiStan SET LagerZone = #FillArtiStan.Lagerzone, LagerFach = #FillArtiStan.Lagerfach
    FROM #FillArtiStan
    WHERE #FillArtiStan.ArtikelID = ArtiStan.ArtikelID
      AND #FillArtiStan.StandortID = ArtiStan.StandortID
      AND ArtiStan.Lagerzone IS NULL
      AND ArtiStan.Lagerfach IS NULL;

    INSERT INTO ArtiStan (ArtikelID, StandortID, FaltProgID, FinishPrID, LagerZone, LagerFach, AnlageUserID_, UserID_)
    SELECT #FillArtiStan.ArtikelID, #FillArtiStan.StandortID, DefaultArtiStan.FaltProgID, DefaultArtiStan.FinishPrID, #FillArtiStan.Lagerzone, #FillArtiStan.Lagerfach, @UserID AS AnlageUserID_, @UserID AS UserID_
    FROM #FillArtiStan
    CROSS JOIN (
      SELECT FaltProgID = (SELECT FaltProg.ID FROM FaltProg WHERE FaltProg.IstDefault = 1), FinishPrID = (SELECT FinishPr.ID FROM FinishPr WHERE FinishPr.IstDefault = 1)
    ) AS DefaultArtiStan
    WHERE NOT EXISTS (
      SELECT ASCheck.*
      FROM ArtiStan ASCheck
      WHERE ASCheck.ArtikelID = #FillArtiStan.ArtikelID
        AND ASCheck.StandortID = #FillArtiStan.StandortID
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

GO

DROP TABLE IF EXISTS #FillArtiStan;

GO