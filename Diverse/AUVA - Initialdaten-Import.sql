-- DROP TABLE IF EXISTS _auvainitial;

/* IF object_id('Salesianer.dbo._auvainitial') IS NULL
BEGIN
  CREATE TABLE _auvainitial (
    LfdNr int,
    MifareID nchar(10) COLLATE Latin1_General_CS_AS,
    Kartennummer nchar(8) COLLATE Latin1_General_CS_AS NOT NULL,
    [Status] nchar(7) COLLATE Latin1_General_CS_AS NOT NULL,
    Typ nchar(7) COLLATE Latin1_General_CS_AS NOT NULL,
    Vorname nvarchar(30) COLLATE Latin1_General_CS_AS,
    Nachname nvarchar(30) COLLATE Latin1_General_CS_AS,
    Titel nvarchar(20) COLLATE Latin1_General_CS_AS,
    TitelN nvarchar(20) COLLATE Latin1_General_CS_AS,
    Standort nchar(2) COLLATE Latin1_General_CS_AS NOT NULL,
    Kostenstelle nchar(6) COLLATE Latin1_General_CS_AS NOT NULL
  );
END; */

ALTER TABLE _auvainitial ALTER COLUMN MifareID nchar(10) COLLATE Latin1_General_CS_AS;
ALTER TABLE _auvainitial ALTER COLUMN Kartennummer nchar(8) COLLATE Latin1_General_CS_AS NOT NULL;
ALTER TABLE _auvainitial ALTER COLUMN [Status] nchar(7) COLLATE Latin1_General_CS_AS NOT NULL;
ALTER TABLE _auvainitial ALTER COLUMN Typ nchar(7) COLLATE Latin1_General_CS_AS NOT NULL;
ALTER TABLE _auvainitial ALTER COLUMN Vorname nvarchar(30) COLLATE Latin1_General_CS_AS;
ALTER TABLE _auvainitial ALTER COLUMN Nachname nvarchar(30) COLLATE Latin1_General_CS_AS;
ALTER TABLE _auvainitial ALTER COLUMN Titel nvarchar(20) COLLATE Latin1_General_CS_AS;
ALTER TABLE _auvainitial ALTER COLUMN TitelN nvarchar(20) COLLATE Latin1_General_CS_AS;
ALTER TABLE _auvainitial ALTER COLUMN Standort nchar(2) COLLATE Latin1_General_CS_AS NOT NULL;
ALTER TABLE _auvainitial ALTER COLUMN Kostenstelle nchar(6) COLLATE Latin1_General_CS_AS NOT NULL;

/* Import über SSMS in Tabelle _auvainitial - Struktur siehe oben */

SELECT * FROM _auvainitial;

UPDATE _auvainitial SET Kartennummer = RIGHT(REPLICATE(N'0', 8) + RTRIM(Kartennummer), 8) WHERE LEN(Kartennummer) != 8;
-- SELECT ISNULL(LfdNr, '') AS LfdNr, MifareID, Kartennummer, Status, Typ, Vorname, Nachname, Titel, TitelN, ISNULL(Standort, '') AS Standort, ISNULL(Kostenstelle, '') AS Kostenstelle FROM _auvainitial WHERE Standort IS NULL;
-- SELECT DISTINCT Standort FROM _auvainitial;

DROP TABLE IF EXISTS #TmpImport;

SELECT x.MifareID AS Kartennummer, x.Kartennummer AS PersNr, x.Status, x.Typ AS Kartentyp, x.Vorname, x.Nachname, x.Titel, x.TitelN, x.Standort, x.Kostenstelle, Rentomat.ID AS RentomatID
INTO #TmpImport
FROM _auvainitial x
JOIN Rentomat ON Rentomat.SchrankNr LIKE '%' + x.Standort + '%';

SELECT Traeger.PersNr AS Kartennummer, Traeger.Vorname, Traeger.Nachname, Traeger.RentomatKarte AS [MifareID Salesianer], x.Kartennummer AS [MifareID Initialdaten], x.Kartentyp, x.Standort
FROM Traeger, Vsa, #TmpImport x
WHERE Traeger.VsaID = Vsa.ID
  AND Vsa.RentomatID = x.RentomatID
  AND Traeger.PersNr = x.PersNr
  AND Traeger.RentomatKarte <> x.Kartennummer;

/* PersNr auffüllen */
UPDATE Traeger SET PersNr = RIGHT(N'00000000' + Traeger.PersNr, 8)
FROM Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
WHERE Vsa.RentomatID IN (SELECT DISTINCT RentomatID FROM #TmpImport)
  AND Traeger.PersNr <> RIGHT(N'00000000' + Traeger.PersNr, 8)
  AND Traeger.PersNr IS NOT NULL;

/* Personalnummer aus Initialdaten übernehmen wo zuordenbar */
UPDATE Traeger SET Traeger.VormalsNr = i.I_Kartentyp, Traeger.DebitorNr = i.I_Kartennummer, Traeger.Status = 'A', Traeger.Ausdienst = NULL, Traeger.AusdienstDat = NULL, Traeger.PersNr = i.I_PersNr
FROM Traeger, (  
  SELECT Traeger.ID AS TraegerID, Traeger.PersNr, x.PersNr AS I_PersNr, Traeger.Vorname, x.Vorname AS I_Vorname, Traeger.Nachname, x.Nachname AS I_Nachname, x.TitelN AS I_TitelN, Traeger.Titel, x.Titel AS I_Titel, Traeger.RentomatKarte AS Kartennummer, x.Kartennummer AS I_Kartennummer, x.Kartentyp AS I_Kartentyp
  FROM Traeger, Vsa, #TmpImport x
  WHERE Traeger.VsaID = Vsa.ID
    AND Vsa.RentomatID = x.RentomatID
    AND Traeger.PersNr != x.PersNr
    AND LTRIM(RTRIM(UPPER(Traeger.Vorname))) = LTRIM(RTRIM(UPPER(x.Vorname)))
    AND LTRIM(RTRIM(UPPER(Traeger.Nachname))) = LTRIM(RTRIM(UPPER(x.Nachname)))
    AND Traeger.RentomatKarte = x.Kartennummer
) AS i
WHERE i.TraegerID = Traeger.ID;

UPDATE Traeger SET Traeger.Status = 'I', Traeger.RentomatKarte = NULL, Traeger.Ausdienst = NULL, Traeger.AusdienstDat = NULL
WHERE Traeger.VsaID IN (SELECT Vsa.ID FROM Vsa WHERE Vsa.RentomatID IN (SELECT RentomatID FROM #TmpImport))
  AND Traeger.RentoArtID IN (1, 2);

UPDATE Traeger SET Traeger.RentomatKarte = i.I_Kartennummer, Traeger.DebitorNr = i.I_Kartennummer, Traeger.Status = 'A', Traeger.VormalsNr = i.I_Kartentyp, Traeger.Ausdienst = NULL, Traeger.AusdienstDat = NULL
FROM Traeger, (
  SELECT Traeger.ID AS TraegerID, Traeger.PersNr, x.PersNr AS I_PersNr, Traeger.Vorname, x.Vorname AS I_Vorname, Traeger.Nachname, x.Nachname AS I_Nachname, x.TitelN AS I_TitelN, Traeger.Titel, x.Titel AS I_Titel, Traeger.RentomatKarte AS Kartennummer, x.Kartennummer AS I_Kartennummer, x.Kartentyp AS I_Kartentyp
  FROM Traeger, Vsa, #TmpImport x
  WHERE Traeger.VsaID = Vsa.ID
    AND Vsa.RentomatID = x.RentomatID
    AND Traeger.PersNr = x.PersNr
) AS i
WHERE i.TraegerID = Traeger.ID;

UPDATE Traeger SET Traeger.Vorname = LEFT(i.I_Vorname, 20), Traeger.DebitorNr = i.I_Kartennummer, Traeger.Status = 'A', Traeger.VormalsNr = i.I_Kartentyp, Traeger.Ausdienst = NULL, Traeger.AusdienstDat = NULL
FROM Traeger, (
  SELECT Traeger.ID AS TraegerID, Traeger.PersNr, x.PersNr AS I_PersNr, Traeger.Vorname, x.Vorname AS I_Vorname, Traeger.Nachname, x.Nachname AS I_Nachname, x.TitelN AS I_TitelN, Traeger.Titel, x.Titel AS I_Titel, Traeger.RentomatKarte AS Kartennummer, x.Kartennummer AS I_Kartennummer, x.Kartentyp AS I_Kartentyp
  FROM Traeger, Vsa, #TmpImport x
  WHERE Traeger.VsaID = Vsa.ID
    AND Vsa.RentomatID = x.RentomatID
    AND Traeger.PersNr = x.PersNr
    AND Traeger.Vorname <> x.Vorname
) AS i
WHERE i.TraegerID = Traeger.ID;

UPDATE Traeger SET Traeger.Titel = i.I_Titel, Traeger.DebitorNr = i.I_Kartennummer, Traeger.Status = 'A', Traeger.VormalsNr = i.I_Kartentyp, Traeger.Ausdienst = NULL, Traeger.AusdienstDat = NULL
FROM Traeger, (
  SELECT Traeger.ID AS TraegerID, Traeger.PersNr, x.PersNr AS I_PersNr, Traeger.Vorname, x.Vorname AS I_Vorname, Traeger.Nachname, x.Nachname AS I_Nachname, x.TitelN AS I_TitelN, Traeger.Titel, x.Titel AS I_Titel, Traeger.RentomatKarte AS Kartennummer, x.Kartennummer AS I_Kartennummer, x.Kartentyp AS I_Kartentyp
  FROM Traeger, Vsa, #TmpImport x
  WHERE Traeger.VsaID = Vsa.ID
    AND Vsa.RentomatID = x.RentomatID
    AND Traeger.PersNr = x.PersNr
    AND Traeger.Titel <> x.Titel
) AS i
WHERE i.TraegerID = Traeger.ID;

UPDATE Traeger SET Traeger.Nachname = LEFT(i.I_Nachname, 25), Traeger.DebitorNr = i.I_Kartennummer, Traeger.Status = 'A', Traeger.VormalsNr = i.I_Kartentyp, Traeger.Ausdienst = NULL, Traeger.AusdienstDat = NULL
FROM Traeger, (
  SELECT Traeger.ID AS TraegerID, Traeger.PersNr, x.PersNr AS I_PersNr, Traeger.Vorname, x.Vorname AS I_Vorname, Traeger.Nachname, RTRIM(x.Nachname) + IIF(x.TitelN IS NULL, N'', ', ') + ISNULL(x.TitelN, '') AS I_Nachname, Traeger.Titel, x.Titel AS I_Titel, Traeger.RentomatKarte AS Kartennummer, x.Kartennummer AS I_Kartennummer, x.Kartentyp AS I_Kartentyp
  FROM Traeger, Vsa, #TmpImport x
  WHERE Traeger.VsaID = Vsa.ID
    AND Vsa.RentomatID = x.RentomatID
    AND Traeger.PersNr = x.PersNr
    AND Traeger.Nachname <> x.Nachname + ISNULL(x.TitelN, '')
) AS i
WHERE i.TraegerID = Traeger.ID;

UPDATE Traeger SET Traeger.AbteilID = i.I_AbteilID, Traeger.DebitorNr = i.I_Kartennummer, Traeger.Status = 'A', Traeger.VormalsNr = i.I_Kartentyp, Traeger.Ausdienst = NULL, Traeger.AusdienstDat = NULL
FROM Traeger, (
  SELECT Traeger.ID AS TraegerID, Traeger.PersNr, x.PersNr AS I_PersNr, Traeger.Vorname, x.Vorname AS I_Vorname, Traeger.Nachname, RTRIM(x.Nachname) + ', ' + ISNULL(x.TitelN, '') AS I_Nachname, Traeger.Titel, x.Titel AS I_Titel, Traeger.RentomatKarte AS Kartennummer, x.Kartennummer AS I_Kartennummer, Abteil.ID AS I_AbteilID, x.Kartentyp AS I_Kartentyp
  FROM Traeger, Vsa, Abteil, #TmpImport x
  WHERE Traeger.VsaID = Vsa.ID
    AND Vsa.RentomatID = x.RentomatID
    AND Traeger.PersNr = x.PersNr
    AND Traeger.Nachname <> x.Nachname + ISNULL(x.TitelN, '')
    AND Abteil.Abteilung = x.Kostenstelle
    AND Abteil.KundenID = Vsa.KundenID
) AS i
WHERE i.TraegerID = Traeger.ID;

UPDATE Traeger SET Traeger.AbteilID = i.I_AbteilID, Traeger.DebitorNr = i.I_Kartennummer, Traeger.Status = 'A', Traeger.VormalsNr = i.I_Kartentyp, Traeger.Ausdienst = NULL, Traeger.AusdienstDat = NULL
FROM Traeger, (
  SELECT Traeger.ID AS TraegerID, Traeger.PersNr, x.PersNr AS I_PersNr, Traeger.Vorname, x.Vorname AS I_Vorname, Traeger.Nachname, RTRIM(x.Nachname) + ', ' + ISNULL(x.TitelN, '') AS I_Nachname, Traeger.Titel, x.Titel AS I_Titel, Traeger.RentomatKarte AS Kartennummer, x.Kartennummer AS I_Kartennummer, Abteil.ID AS I_AbteilID, x.Kartentyp AS I_Kartentyp
  FROM Traeger, Vsa, Abteil, #TmpImport x
  WHERE Traeger.VsaID = Vsa.ID
    AND Vsa.RentomatID = x.RentomatID
    AND Traeger.PersNr = x.PersNr
    AND Traeger.Nachname = x.Nachname + ISNULL(x.TitelN, '')
    AND Abteil.Abteilung = x.Kostenstelle
    AND Abteil.KundenID = Vsa.KundenID
    AND Traeger.AbteilID != Abteil.ID
) AS i
WHERE i.TraegerID = Traeger.ID;

UPDATE Traeger SET Traeger.VormalsNr = i.I_Kartentyp, Traeger.DebitorNr = i.I_Kartennummer, Traeger.Status = 'A', Traeger.Ausdienst = NULL, Traeger.AusdienstDat = NULL
FROM Traeger, (
  SELECT Traeger.ID AS TraegerID, Traeger.PersNr, x.PersNr AS I_PersNr, Traeger.Vorname, x.Vorname AS I_Vorname, Traeger.Nachname, RTRIM(x.Nachname) + ', ' + ISNULL(x.TitelN, '') AS I_Nachname, Traeger.Titel, x.Titel AS I_Titel, Traeger.RentomatKarte AS Kartennummer, x.Kartennummer AS I_Kartennummer, x.Kartentyp AS I_Kartentyp
  FROM Traeger, Vsa, #TmpImport x
  WHERE Traeger.VsaID = Vsa.ID
    AND Vsa.RentomatID = x.RentomatID
    AND Traeger.PersNr = x.PersNr
    AND Traeger.Nachname <> x.Nachname + ISNULL(x.TitelN, '')
) AS i
WHERE i.TraegerID = Traeger.ID;

-- Noch nicht im AdvanTex vorhandene Träger oder Träger mit falscher Kostenstelle wieder in .csv-File exportieren und über Schnittstelle importieren, damit diese angelegt werden
SELECT ROW_NUMBER() OVER (ORDER BY ImportData.PersNr) AS LfdNr, RTRIM(ImportData.Kartennummer) AS MifareID, ImportData.PersNr AS Kartennummer, RTRIM(ImportData.Status) AS Status, RTRIM(ImportData.Kartentyp) AS Typ, RTRIM(ISNULL(ImportData.Vorname, N'')) AS Vorname, RTRIM(ISNULL(ImportData.Nachname, N'')) AS Nachname, RTRIM(ISNULL(ImportData.Titel, N'')) AS Titel, RTRIM(ISNULL(ImportData.TitelN, N'')) AS TitelN, ImportData.Standort, ImportData.Kostenstelle
FROM #TmpImport ImportData
WHERE NOT EXISTS (
  SELECT Traeger.ID
  FROM Traeger
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  JOIN Abteil ON Traeger.AbteilID = Abteil.ID
  WHERE Vsa.RentomatID = ImportData.RentomatID
    AND Traeger.PersNr = ImportData.PersNr 
    AND Abteil.Abteilung = ImportData.Kostenstelle
);

-- Check ob alle Datensätze verarbeitet wurden
SELECT Traeger.*
FROM Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
WHERE Vsa.RentomatID IN (SELECT RentomatID FROM #TmpImport)
  AND Traeger.Status = N'A'
  AND Traeger.RentomatKarte IS NOT NULL
  AND Traeger.Update_ > N'2023-01-25 09:30:00';

SELECT Traeger.RentomatKarte
FROM Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
WHERE Vsa.RentomatID IN (SELECT RentomatID FROM #TmpImport)
  AND Traeger.Status = N'I'
  AND Traeger.Update_ > N'2023-01-25 09:30:00'
  AND Traeger.UserID_ = (SELECT Mitarbei.ID FROM Mitarbei WHERE UserName = N'THALST');

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Einzeltests                                                                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
SELECT Traeger.ID, ISNULL(Traeger.RentomatKarte, N'') AS MifareID, Traeger.PersNr AS Kartennummer, Status.StatusBez AS Status, ISNULL(Traeger.VormalsNr, N'') AS Kartentyp, ISNULL(Traeger.Vorname, N'') AS Vorname, ISNULL(Traeger.Nachname, N'') AS Nachname, ISNULL(Traeger.Titel, N'') AS Titel, ISNULL(Abteil.Abteilung, N'') AS Kostenstelle, Kunden.KdNr, Kunden.SuchCode AS Kunde, Traeger.Update_ AS [letztes Datensatz-Update]
FROM Traeger, Vsa, Kunden, Abteil, (SELECT Status.Status, Status.StatusBez FROM Status WHERE Status.Tabelle = 'TRAEGER') AS Status
WHERE Traeger.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Traeger.AbteilID = Abteil.ID
  AND Traeger.Status = Status.Status
  AND Traeger.PersNr IN (N'00112260');

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Auswertung zur Datenprüfung                                                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
SELECT Kunden.KdNr, RTRIM(Kunden.SuchCode) AS Kunde, ISNULL(RTRIM(Traeger.RentomatKarte), N'') AS MifareID, RTRIM(Traeger.PersNr) AS Kartennummer, [Status].StatusBez AS [Status], ISNULL(RTRIM(Traeger.VormalsNr), N'') AS Kartentyp, ISNULL(RTRIM(Traeger.Vorname), N'') AS Vorname, ISNULL(RTRIM(Traeger.Nachname), N'') AS Nachname, ISNULL(RTRIM(Traeger.Titel), N'') AS Titel, ISNULL(RTRIM(Abteil.Abteilung), N'') AS Kostenstelle, IIF(Traeger.RentoArtID < 0, 0, 1) AS Bekleidungsprofil, Traeger.Anlage_
FROM Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden oN Vsa.KundenID = Kunden.ID
JOIN Rentomat ON Vsa.RentomatID = Rentomat.ID
JOIN [Status] ON Traeger.[Status] = [Status].[Status] AND [Status].[Tabelle] = N'TRAEGER'
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
WHERE Rentomat.SchrankNr LIKE N'%<UL>%'
  AND Traeger.Status = N'A'
  AND Traeger.RentomatKarte IS NOT NULL;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Doppelte Träger finden                                                                                                    ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

WITH doublewearer AS (
  SELECT Traeger.RentomatKarte, COUNT(Traeger.ID) AS [Anzahl Träger]
  FROM Traeger
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  JOIN Kunden oN Vsa.KundenID = Kunden.ID
  JOIN Rentomat ON Vsa.RentomatID = Rentomat.ID
  JOIN [Status] ON Traeger.[Status] = [Status].[Status] AND [Status].[Tabelle] = N'TRAEGER'
  JOIN Abteil ON Traeger.AbteilID = Abteil.ID
  WHERE Rentomat.SchrankNr LIKE N'%RW%'
    AND Traeger.Status = N'A'
    AND Traeger.RentomatKarte IS NOT NULL
  GROUP BY Traeger.RentomatKarte
  HAVING COUNT(Traeger.ID) > 1
)
SELECT Traeger.Traeger, Traeger.PersNr, Traeger.Vorname, Traeger.Nachname, Traeger.Titel, Traeger.RentomatKarte AS MifareID
FROM Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden oN Vsa.KundenID = Kunden.ID
JOIN Rentomat ON Vsa.RentomatID = Rentomat.ID
JOIN [Status] ON Traeger.[Status] = [Status].[Status] AND [Status].[Tabelle] = N'TRAEGER'
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
WHERE Rentomat.SchrankNr LIKE N'%RW%'
  AND Traeger.Status = N'A'
  AND Traeger.RentomatKarte IS NOT NULL
  AND Traeger.RentomatKarte IN (SELECT RentomatKarte FROM doublewearer)
ORDER BY PersNr ASC;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Rollback - reactivate deactivated wearers                                                                                 ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

/* 
DECLARE @RecativateWearer TABLE (
  TraegerID int PRIMARY KEY NOT NULL,
  RentomatKarte nvarchar(25) COLLATE Latin1_General_CS_AS
);

INSERT INTO @RecativateWearer (TraegerID, RentomatKarte)
SELECT Traeger.ID, tt.RentomatKarte
FROM Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Salesianer_Test.dbo.Traeger tt ON tt.ID = Traeger.ID
WHERE Vsa.RentomatID = 38
  AND Traeger.Update_ > N'2023-01-25 09:30:00'
  --AND Traeger.UserID_ = (SELECT Mitarbei.ID FROM Mitarbei WHERE UserName = N'THALST')
  AND Traeger.[Status] = N'I'
  AND NOT EXISTS (
    SELECT t.*
    FROM Salesianer_Test.dbo.Traeger t
    JOIN Salesianer_Test.dbo.Vsa v ON t.VsaID = v.ID
    WHERE v.RentomatID = 38
      AND t.[Status] = N'I'
      AND t.ID = Traeger.ID
  );

UPDATE Traeger SET Status = N'A', RentomatKarte = [@RecativateWearer].RentomatKarte
FROM @RecativateWearer
WHERE [@RecativateWearer].TraegerID = Traeger.ID

GO
*/

