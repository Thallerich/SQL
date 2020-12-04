WITH DeisterBHSTraeger AS (
  SELECT PersNr, KartenNr, KdNr, KsSt, CONVERT(date, Indienst, 112) AS Indienst, CONVERT(date, Ausdiens, 112) AS Ausdienst
  FROM __DeisterBHS
)
INSERT INTO Traeger (VsaID, Status, Traeger, AbteilID, PersNr, Vorname, Nachname, Indienst, IndienstDat)
SELECT Vsa.ID AS VsaID, N'A' AS Status, ROW_NUMBER() OVER (ORDER BY PersNr) AS Traeger, Abteil.ID AS AbteilID, DeisterBHSTraeger.PersNr, N'--' AS Vorname, N'--' AS Nachname, Week.Woche AS Indienst, DeisterBHSTraeger.Indienst AS IndienstDat
FROM DeisterBHSTraeger
JOIN Kunden ON DeisterBHSTraeger.KdNr = Kunden.KdNr
JOIN Vsa ON Vsa.KundenID = Kunden.ID
JOIN Week ON IIF(DeisterBHSTraeger.Indienst < N'1980-01-01', N'1980-01-01', DeisterBHSTraeger.Indienst) BETWEEN Week.VonDat AND Week.BisDat
JOIN Abteil ON Abteil.KundenID = Kunden.ID AND Abteil.Abteilung = ISNULL(DeisterBHSTraeger.KsSt, N'Dummy') COLLATE Latin1_General_CS_AS
WHERE Vsa.RentomatID > 0;

WITH DeisterBHSTraeger AS (
  SELECT PersNr, KartenNr, KdNr, KsSt, CONVERT(date, Indienst, 112) AS Indienst, CONVERT(date, Ausdiens, 112) AS Ausdienst
  FROM __DeisterBHS
  WHERE Ausdiens != N'99991231'
)
UPDATE Traeger SET Traeger.AusdienstDat = DeisterBHSTraeger.Ausdienst, Traeger.Ausdienst = AusWeek.Woche, Traeger.Status = IIF(DeisterBHSTraeger.Ausdienst < CAST(GETDATE() AS date), N'I', N'A')
--SELECT Traeger.ID AS TraegerID, Traeger.VsaID, Traeger.AusdienstDat, DeisterBHSTraeger.Ausdienst, AusWeek.Woche, IIF(DeisterBHSTraeger.Ausdienst < CAST(GETDATE() AS date), N'I', N'A') AS Traegerstatus
FROM Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN DeisterBHSTraeger ON DeisterBHSTraeger.KdNr = Kunden.KdNr AND DeisterBHSTraeger.PersNr = Traeger.PersNr COLLATE Latin1_General_CS_AS AND DeisterBHSTraeger.Indienst = Traeger.IndienstDat
JOIN Week ON IIF(DeisterBHSTraeger.Indienst < N'1980-01-01', N'1980-01-01', DeisterBHSTraeger.Indienst) BETWEEN Week.VonDat AND Week.BisDat
JOIN Week AS AusWeek ON DeisterBHSTraeger.Ausdienst BETWEEN AusWeek.VonDat AND AusWeek.BisDat
WHERE Vsa.RentomatID > 0;