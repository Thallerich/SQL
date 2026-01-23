DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = UPPER(REPLACE(ORIGINAL_LOGIN(), N'SAL\', N'')));

BEGIN TRY
  BEGIN TRANSACTION;
  
    INSERT INTO Hinweis (EinzHistID, EinzTeilID, Aktiv, Hinweis, BisWoche, Anzahl, EingabeDatum, HinwTextID, EingabeMitarbeiID, AnlageUserID_, UserID_)
    SELECT EinzHist.ID AS EinzHistID, EinzHist.EinzTeilID, CAST(1 AS bit) AS Aktiv, N'Kundenservice (SM) - UHF-Chip prüfen/zuordnen' AS Hinweis, '2099/52' AS BisWoche, 1 AS Anzahl, GETDATE() AS Eingabedatum, 1000539 AS HinwTextID, @userid AS EingabeMitarbID, @userid AS AnlageUserID_, @userid AS UserID_
    FROM EinzTeil
    JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
    WHERE EinzTeil.Code IN (SELECT Code FROM Salesianer.._SAWRKsHinweis)
      AND EinzHist.EinzHistTyp = 1;

    INSERT INTO Hinweis (EinzHistID, EinzTeilID, Aktiv, Hinweis, BisWoche, Anzahl, EingabeDatum, HinwTextID, EingabeMitarbeiID, AnlageUserID_, UserID_)
    SELECT EinzHist.ID AS EinzHistID, EinzHist.EinzTeilID, CAST(1 AS bit) AS Aktiv, N'Label erneuern (SM) - UHF-Chip prüfen/zuordnen' AS Hinweis, '2099/52' AS BisWoche, 1 AS Anzahl, GETDATE() AS Eingabedatum, 1000524 AS HinwTextID, @userid AS EingabeMitarbID, @userid AS AnlageUserID_, @userid AS UserID_
    FROM EinzTeil
    JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
    WHERE EinzTeil.Code IN (SELECT Code FROM Salesianer.._SAWRLableHinweis)
      AND EinzHist.EinzHistTyp = 1; 
  
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