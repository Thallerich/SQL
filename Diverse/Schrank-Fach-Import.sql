DROP TABLE IF EXISTS #TmpFachzuordnung;

GO

CREATE TABLE #TmpFachzuordnung (
  TraegerID int,
  TraeFachID int
);

GO

WITH FachImport AS (
  SELECT DISTINCT KdNr, VsaNr, KsSt, Nachname, Vorname, Schrank, Fach
  FROM Salesianer.dbo._FachImport
  WHERE Schrank IS NOT NULL
    AND Fach IS NOT NULL
)
INSERT INTO #TmpFachzuordnung (TraegerID, TraeFachID)
SELECT Traeger.ID AS TraegerID, TraeFach.ID AS TraeFachID
FROM Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN FachImport ON Kunden.KdNr = FachImport.KdNr AND Vsa.VsaNr = FachImport.VsaNr AND Traeger.Nachname = FachImport.Nachname COLLATE Latin1_General_CS_AS AND Traeger.Vorname = FachImport.Vorname COLLATE Latin1_General_CS_AS
JOIN Schrank ON Schrank.VsaID = Vsa.ID AND Schrank.SchrankNr = FachImport.Schrank COLLATE Latin1_General_CS_AS
JOIN TraeFach ON TraeFach.SchrankID = Schrank.ID AND TraeFach.Fach = FachImport.Fach;

GO

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE TraeFach SET TraegerID = #TmpFachzuordnung.TraegerID
    FROM #TmpFachzuordnung
    WHERE #TmpFachzuordnung.TraeFachID = TraeFach.ID;
  
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

DROP TABLE _FachImport;
GO