/* ## Alter Collation of imported data to match AdvanTex tables ## */
/*
ALTER TABLE __auvainitial ALTER COLUMN MifareID nchar(10) COLLATE Latin1_General_CS_AS
ALTER TABLE __auvainitial ALTER COLUMN Kartennummer nchar(8) COLLATE Latin1_General_CS_AS
ALTER TABLE __auvainitial ALTER COLUMN Status nchar(7) COLLATE Latin1_General_CS_AS
ALTER TABLE __auvainitial ALTER COLUMN Typ nchar(7) COLLATE Latin1_General_CS_AS
ALTER TABLE __auvainitial ALTER COLUMN Vorname nvarchar(30) COLLATE Latin1_General_CS_AS
ALTER TABLE __auvainitial ALTER COLUMN Nachname nvarchar(30) COLLATE Latin1_General_CS_AS
ALTER TABLE __auvainitial ALTER COLUMN Titel nvarchar(20) COLLATE Latin1_General_CS_AS
ALTER TABLE __auvainitial ALTER COLUMN TitelN nvarchar(20) COLLATE Latin1_General_CS_AS
ALTER TABLE __auvainitial ALTER COLUMN Standort nchar(2) COLLATE Latin1_General_CS_AS
ALTER TABLE __auvainitial ALTER COLUMN Kostenstelle nchar(6) COLLATE Latin1_General_CS_AS
*/

DROP TABLE IF EXISTS #TmpImport;

SELECT x.MifareID AS Kartennummer, x.Kartennummer AS PersNr, x.Status, x.Typ AS Kartentyp, x.Vorname, x.Nachname, x.Titel, x.TitelN, x.Standort, x.Kostenstelle, Rentomat.ID AS RentomatID
INTO #TmpImport
FROM __auvainitial x
JOIN Rentomat ON Rentomat.SchrankNr LIKE '%' + x.Standort + '%'
  AND Rentomat.ID = 36; 

/* PersNr auffüllen */
UPDATE Traeger SET PersNr = RIGHT(N'00000000' + Traeger.PersNr, 8)
FROM Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
WHERE Vsa.RentomatID IN (SELECT DISTINCT RentomatID FROM #TmpImport)
  AND Traeger.PersNr <> RIGHT(N'00000000' + Traeger.PersNr, 8);


UPDATE Traeger SET Traeger.Status = 'I', Traeger.RentomatKarte = NULL
WHERE Traeger.VsaID IN (SELECT Vsa.ID FROM Vsa WHERE Vsa.RentomatID IN (SELECT RentomatID FROM #TmpImport))
  AND Traeger.RentoArtID IN (1, 2);

UPDATE Traeger SET Traeger.RentomatKarte = i.I_Kartennummer, Traeger.DebitorNr = i.I_Kartennummer, Traeger.Status = 'A'
FROM Traeger, (
  SELECT Traeger.ID AS TraegerID, Traeger.PersNr, x.PersNr AS I_PersNr, Traeger.Vorname, x.Vorname AS I_Vorname, Traeger.Nachname, x.Nachname AS I_Nachname, x.TitelN AS I_TitelN, Traeger.Titel, x.Titel AS I_Titel, Traeger.RentomatKarte AS Kartennummer, x.Kartennummer AS I_Kartennummer
  FROM Traeger, Vsa, #TmpImport x
  WHERE Traeger.VsaID = Vsa.ID
    AND Vsa.RentomatID = x.RentomatID
    AND Traeger.PersNr = x.PersNr
) AS i
WHERE i.TraegerID = Traeger.ID;

UPDATE Traeger SET Traeger.Vorname = LEFT(i.I_Vorname, 20), Traeger.DebitorNr = i.I_Kartennummer, Traeger.Status = 'A'
FROM Traeger, (
  SELECT Traeger.ID AS TraegerID, Traeger.PersNr, x.PersNr AS I_PersNr, Traeger.Vorname, x.Vorname AS I_Vorname, Traeger.Nachname, x.Nachname AS I_Nachname, x.TitelN AS I_TitelN, Traeger.Titel, x.Titel AS I_Titel, Traeger.RentomatKarte AS Kartennummer, x.Kartennummer AS I_Kartennummer
  FROM Traeger, Vsa, #TmpImport x
  WHERE Traeger.VsaID = Vsa.ID
    AND Vsa.RentomatID = x.RentomatID
    AND Traeger.PersNr = x.PersNr
    AND Traeger.Vorname <> x.Vorname
) AS i
WHERE i.TraegerID = Traeger.ID;

UPDATE Traeger SET Traeger.Titel = i.I_Titel, Traeger.DebitorNr = i.I_Kartennummer, Traeger.Status = 'A'
FROM Traeger, (
  SELECT Traeger.ID AS TraegerID, Traeger.PersNr, x.PersNr AS I_PersNr, Traeger.Vorname, x.Vorname AS I_Vorname, Traeger.Nachname, x.Nachname AS I_Nachname, x.TitelN AS I_TitelN, Traeger.Titel, x.Titel AS I_Titel, Traeger.RentomatKarte AS Kartennummer, x.Kartennummer AS I_Kartennummer
  FROM Traeger, Vsa, #TmpImport x
  WHERE Traeger.VsaID = Vsa.ID
    AND Vsa.RentomatID = x.RentomatID
    AND Traeger.PersNr = x.PersNr
    AND Traeger.Titel <> x.Titel
) AS i
WHERE i.TraegerID = Traeger.ID;

UPDATE Traeger SET Traeger.Nachname = LEFT(i.I_Nachname, 25), Traeger.DebitorNr = i.I_Kartennummer, Traeger.Status = 'A'
FROM Traeger, (
  SELECT Traeger.ID AS TraegerID, Traeger.PersNr, x.PersNr AS I_PersNr, Traeger.Vorname, x.Vorname AS I_Vorname, Traeger.Nachname, RTRIM(x.Nachname) + ', ' + ISNULL(x.TitelN, '') AS I_Nachname, Traeger.Titel, x.Titel AS I_Titel, Traeger.RentomatKarte AS Kartennummer, x.Kartennummer AS I_Kartennummer
  FROM Traeger, Vsa, #TmpImport x
  WHERE Traeger.VsaID = Vsa.ID
    AND Vsa.RentomatID = x.RentomatID
    AND Traeger.PersNr = x.PersNr
    AND Traeger.Nachname <> x.Nachname + ISNULL(x.TitelN, '')
) AS i
WHERE i.TraegerID = Traeger.ID;

UPDATE Traeger SET Traeger.AbteilID = i.I_AbteilID, Traeger.DebitorNr = i.I_Kartennummer, Traeger.Status = 'A'
FROM Traeger, (
  SELECT Traeger.ID AS TraegerID, Traeger.PersNr, x.PersNr AS I_PersNr, Traeger.Vorname, x.Vorname AS I_Vorname, Traeger.Nachname, RTRIM(x.Nachname) + ', ' + ISNULL(x.TitelN, '') AS I_Nachname, Traeger.Titel, x.Titel AS I_Titel, Traeger.RentomatKarte AS Kartennummer, x.Kartennummer AS I_Kartennummer, Abteil.ID AS I_AbteilID
  FROM Traeger, Vsa, Abteil, #TmpImport x
  WHERE Traeger.VsaID = Vsa.ID
    AND Vsa.RentomatID = x.RentomatID
    AND Traeger.PersNr = x.PersNr
    AND Traeger.Nachname <> x.Nachname + ISNULL(x.TitelN, '')
    AND Abteil.Abteilung = x.Kostenstelle
    AND Abteil.KundenID = Vsa.KundenID
) AS i
WHERE i.TraegerID = Traeger.ID;

UPDATE Traeger SET Traeger.VormalsNr = i.I_Kartentyp, Traeger.DebitorNr = i.I_Kartennummer, Traeger.Status = 'A'
FROM Traeger, (
  SELECT Traeger.ID AS TraegerID, Traeger.PersNr, x.PersNr AS I_PersNr, Traeger.Vorname, x.Vorname AS I_Vorname, Traeger.Nachname, RTRIM(x.Nachname) + ', ' + ISNULL(x.TitelN, '') AS I_Nachname, Traeger.Titel, x.Titel AS I_Titel, Traeger.RentomatKarte AS Kartennummer, x.Kartennummer AS I_Kartennummer, x.Kartentyp AS I_Kartentyp
  FROM Traeger, Vsa, #TmpImport x
  WHERE Traeger.VsaID = Vsa.ID
    AND Vsa.RentomatID = x.RentomatID
    AND Traeger.PersNr = x.PersNr
    AND Traeger.Nachname <> x.Nachname + ISNULL(x.TitelN, '')
) AS i
WHERE i.TraegerID = Traeger.ID;

/*
-- Query für Ergebnis-Rückmeldung --

SELECT Traeger.ID, Traeger.RentomatKarte AS MifareID, Traeger.PersNr AS Kartennummer, Status.StatusBez AS Status, Traeger.VormalsNr AS Kartentyp, Traeger.Vorname, Traeger.Nachname, Traeger.Titel, Abteil.Abteilung AS Kostenstelle, Kunden.KdNr, Kunden.SuchCode AS Kunde, Traeger.Update_
FROM Traeger, Vsa, Kunden, Abteil, (SELECT Status.Status, Status.StatusBez FROM Status WHERE Status.Tabelle = 'TRAEGER') AS Status
WHERE Traeger.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Traeger.AbteilID = Abteil.ID
  AND Traeger.Status = Status.Status
  AND Traeger.PersNr IN (N'00109093');

SELECT * FROM #TmpImport WHERE Nachname LIKE N'GRILL%'

--------------------------------------
*/

/*
-- Deaktivieren der nicht in den Initialdaten enthaltenen Kartennummer

BEGIN TRANSACTION;

DISABLE TRIGGER LastModified_TRAEGER_UPDATE ON Wozabal.dbo.TRAEGER;

UPDATE TRAEGER SET Status = 'I', RentomatKarte = NULL WHERE ID IN (
  SELECT Traeger.ID
  FROM Traeger, Vsa, Rentomat
  WHERE Traeger.VsaID = Vsa.ID
    AND Vsa.RentomatID = Rentomat.ID
    AND Rentomat.SchrankNr IS NOT NULL
    AND Traeger.RentoArtID IN (1, 2)
    AND Traeger.Update_ < N'2017-11-28 07:45:00'
);

ENABLE TRIGGER LastModified_TRAEGER_UPDATE ON Wozabal.dbo.TRAEGER;

COMMIT;

---------------------------------------------
*/

/* Personalnummer auffüllen */
/*
UPDATE Traeger SET PersNr = RIGHT(N'00000000' + Traeger.PersNr, 8)
FROM Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
WHERE Vsa.RentomatID = 36
  AND Traeger.PersNr <> RIGHT(N'00000000' + Traeger.PersNr, 8);
*/