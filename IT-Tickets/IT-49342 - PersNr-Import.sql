DECLARE @ImportedData TABLE (
  TraegerID int,
  PersNr_Old nchar(10) COLLATE Latin1_General_CS_AS,
  PersNr_New nchar(10) COLLATE Latin1_General_CS_AS
);

WITH ImportData AS (
  SELECT Traeger.ID AS TraegerID, __PersNrImport19010.PersNr AS ImportPersNr
  FROM __PersNrImport19010
  JOIN Traeger ON UPPER(__PersNrImport19010.Vorname) = UPPER(Traeger.Nachname) AND UPPER(__PersNrImport19010.Nachname) = UPPER(Traeger.Vorname)
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN Abteil ON Traeger.AbteilID = Abteil.ID
  WHERE Kunden.KdNr = 19010
    AND Traeger.Status = N'A'
    AND UPPER(__PersNrImport19010.KsSt) = UPPER(Abteil.Bez)
)
UPDATE Traeger SET PersNr = ImportData.ImportPersNr
OUTPUT inserted.ID, deleted.PersNr, inserted.PersNr
INTO @ImportedData (TraegerID, PersNr_Old, PersNr_New)
FROM Traeger
JOIN ImportData ON ImportData.TraegerID = Traeger.ID;

SELECT Traeger.Traeger AS TrägerNr, ImportedData.PersNr_Old AS [Personalnummer bisher], ImportedData.PersNr_New AS [Personalnummer neu], Traeger.Vorname, Traeger.Nachname, Abteil.Bez AS Kostenstelle
FROM @ImportedData AS ImportedData
JOIN Traeger ON ImportedData.TraegerID = Traeger.ID
JOIN Abteil ON Traeger.AbteilID = Abteil.ID;