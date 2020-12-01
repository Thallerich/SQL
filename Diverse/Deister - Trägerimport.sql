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