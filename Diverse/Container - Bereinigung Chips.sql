DROP TABLE IF EXISTS #EinzTeilContain;
GO

SELECT EinzTeil.ID, EinzTeil.Code, EinzTeil.[Status], EinzTeil.LastScanTime, EinzTeil.Anlage_, EinzTeil.AnlageUserID_, IsContainer = 
  CASE
    WHEN EXISTS (SELECT 1 FROM Contain WHERE EinzTeil.Code = Contain.Barcode) THEN 1
    ELSE 0
  END
INTO #EinzTeilContain
FROM EinzTeil
WHERE EinzTeil.Code LIKE N'010005%'
  AND LEN(EinzTeil.Code) = 24;

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Teile, die auch bereits als Container angelegt sind                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = UPPER(REPLACE(ORIGINAL_LOGIN(), N'SAL\', N'')));

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE EinzTeil SET Code = Code + N'*CONT', UserID_ = @userid
    WHERE ID IN (SELECT ID FROM #EinzTeilContain WHERE IsContainer = 1);

    UPDATE EinzHist SET Barcode = Barcode + N'*CONT', UserID_ = @userid
    WHERE EinzHist.EinzTeilID IN (SELECT ID FROM #EinzTeilContain WHERE IsContainer = 1)
      AND EinzHist.ID = (SELECT EinzTeil.CurrEinzHistID FROM EinzTeil WHERE EinzTeil.ID = EinzHist.EinzTeilID);
  
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

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Teile, die noch nicht als Container angelegt sind                                                                         ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = UPPER(REPLACE(ORIGINAL_LOGIN(), N'SAL\', N'')));

BEGIN TRY
  BEGIN TRANSACTION;

    INSERT INTO Contain (Barcode, ArtikelID, AnlageUserID_, UserID_)
    SELECT Code, 1238290 AS ArtikelID, @userid, @userid
    FROM #EinzTeilContain
    WHERE IsContainer = 0;
    
    UPDATE EinzTeil SET Code = Code + N'*CONT', UserID_ = @userid
    WHERE ID IN (SELECT ID FROM #EinzTeilContain WHERE IsContainer = 0);

    UPDATE EinzHist SET Barcode = Barcode + N'*CONT', UserID_ = @userid
    WHERE EinzHist.EinzTeilID IN (SELECT ID FROM #EinzTeilContain WHERE IsContainer = 0)
      AND EinzHist.ID = (SELECT EinzTeil.CurrEinzHistID FROM EinzTeil WHERE EinzTeil.ID = EinzHist.EinzTeilID);
  
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

/*
SELECT LEFT(Contain.Barcode, 6), COUNT(Contain.ID) AS Anzahl
FROM Contain
WHERE LEN(Contain.Barcode) = 24
GROUP BY LEFT(Contain.Barcode, 6)

SELECT Contain.ID, Contain.Barcode, LastContainHist = (SELECT TOP 1 ContHist.Anlage_ FROM ContHist WHERE ContHist.ContainID = Contain.ID AND ContHist.KundenID > 0 ORDER BY ContHist.ID DESC), IsAlsoEinzTeil = CASE WHEN EXISTS (SELECT 1 FROM EinzTeil WHERE EinzTeil.Code = Contain.Barcode) THEN 1 ELSE 0 END
FROM Contain
WHERE LEFT(Contain.Barcode, 6) = 'E20034'
ORDER BY LastContainHist DESC

*/

