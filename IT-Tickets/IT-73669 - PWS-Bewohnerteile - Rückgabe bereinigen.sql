SET NOCOUNT ON;
SET CONTEXT_INFO 0x1; /* AdvanTex-Trigger für RepQueue deaktivieren */
GO

DROP TABLE IF EXISTS #PWSCleanup;
GO

CREATE TABLE #PWSCleanup (
  EinzHistID int PRIMARY KEY CLUSTERED
);

GO

DECLARE @kdgfid int = (SELECT KdGf.ID FROM KdGf WHERE KdGf.KurzBez = N'MED');
DECLARE @msg nvarchar(max);

DECLARE @Hauptstandort TABLE (
  StandortID int,
  StandortKuerzel nchar(4) COLLATE Latin1_General_CS_AS
);

INSERT INTO @Hauptstandort (StandortID, StandortKuerzel)
SELECT Standort.ID, Standort.SuchCode
FROM Standort
WHERE Standort.SuchCode IN (N'WOEN', N'WOLI');

SELECT @msg = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss', N'de-AT') + N': Starte Ermittlung falscher Rückgabe-Teile';
RAISERROR(@msg, 0, 1) WITH NOWAIT;

INSERT INTO #PWSCleanup (EinzHistID)
SELECT EinzHist.ID
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
JOIN Eigentum ON KdArti.EigentumID = Eigentum.ID
WHERE Kunden.KdGFID = @kdgfid
  AND Kunden.StandortID IN (SELECT StandortID FROM @Hauptstandort)
  AND EinzTeil.AltenheimModus IN (1, 2)
  AND EinzHist.Status = N'W'
  AND Eigentum.RueckgabeBew = 0
  AND EinzHist.EinzHistTyp = 1
  AND EinzHist.TraeArtiID != -1;

SELECT @msg = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss', N'de-AT') + N': Anzahl falscher Rückgabe-Teile = ' + FORMAT(@@ROWCOUNT, N'N0', N'de-AT');
RAISERROR(@msg, 0, 1) WITH NOWAIT;

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE EinzHist SET [Status] = N'Q', Abmeldung = NULL, AbmeldDat = NULL, Ausdienst = NULL, AusdienstDat = NULL, AusdienstGrund = NULL, Einzug = NULL
    WHERE ID IN (SELECT EinzHistID FROM #PWSCleanup);
  
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

SELECT @msg = FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss', N'de-AT') + N': Korrekter falscher Rückgabe-Teile abgeschlossen';
RAISERROR(@msg, 0, 1) WITH NOWAIT;

GO

DROP TABLE #PWSCleanup;
GO