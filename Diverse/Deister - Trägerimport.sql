/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ 0,3,16,40,106,112,124,135,143,152                                                                                         ++ */
/* ++                                                                                                                           ++ */
/* ++ Column1 → TNr smallint                                                                                                    ++ */
/* ++ Column2 → PersNr nchar(14)                                                                                                ++ */
/* ++ Column3 → KartenNr nchar(20)                                                                                              ++ */
/* ++ Column5 → KdNr smallint                                                                                                   ++ */
/* ++ Column6 → KsSt nvarchar(50)                                                                                               ++ */
/* ++ Column8 → Indienst nchar(8)                                                                                               ++ */
/* ++ Column9 → Ausdienst nchar(8)                                                                                              ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @MaxTraegerNr int = (SELECT MAX(CAST(Traeger.Traeger AS int)) FROM Traeger WHERE Traeger.VsaID = 6119607);

WITH DeisterBHSTraeger AS (
    SELECT LTRIM(RTRIM(PersNr)) AS PersNr, LTRIM(RTRIM(KartenNr)) AS KartenNr, KdNr, LTRIM(RTRIM(KsSt)) AS KsSt, CONVERT(date, Indienst, 112) AS Indienst, CONVERT(date, Ausdienst, 112) AS Ausdienst
    FROM Salesianer.dbo.__DeisterBHS
  )
MERGE INTO Traeger
USING (
  SELECT Vsa.ID AS VsaID, IIF(DeisterBHSTraeger.Ausdienst < CAST(GETDATE() AS date), N'I', N'A') AS Status, @MaxTraegerNr + ROW_NUMBER() OVER (ORDER BY PersNr) AS Traeger, Abteil.ID AS AbteilID, DeisterBHSTraeger.PersNr, N'--' AS Vorname, N'--' AS Nachname, Week.Woche AS Indienst, DeisterBHSTraeger.Indienst AS IndienstDat, IIF(AusWeek.Woche = N'2050/52', NULL, AusWeek.Woche) AS Ausdienst, IIF(DeisterBHSTraeger.Ausdienst = N'9999-12-31', NULL, DeisterBHSTraeger.Ausdienst) AS AusdienstDat
  FROM DeisterBHSTraeger
  JOIN Kunden ON DeisterBHSTraeger.KdNr = Kunden.KdNr
  JOIN Vsa ON Vsa.KundenID = Kunden.ID
  JOIN Week ON IIF(DeisterBHSTraeger.Indienst < N'1980-01-01', N'1980-01-01', DeisterBHSTraeger.Indienst) BETWEEN Week.VonDat AND Week.BisDat
  JOIN Week AS AusWeek ON IIF(DeisterBHSTraeger.Ausdienst > N'2050-12-31', N'2050-12-31', DeisterBHSTraeger.Ausdienst) BETWEEN AusWeek.VonDat AND AusWeek.BisDat
  JOIN Abteil ON Abteil.KundenID = Kunden.ID AND Abteil.Abteilung = ISNULL(DeisterBHSTraeger.KsSt, N'Dummy') COLLATE Latin1_General_CS_AS
  WHERE Vsa.RentomatID > 0
) AS DeisterImport (VsaID, Status, Traeger, AbteilID, PersNr, Vorname, Nachname, Indienst, IndienstDat, Ausdienst, AusdienstDat)
ON DeisterImport.VsaID = Traeger.VsaID AND DeisterImport.PersNr = Traeger.PersNr COLLATE Latin1_General_CS_AS
WHEN MATCHED THEN
  UPDATE SET Traeger.Status = DeisterImport.Status, Traeger.Indienst = DeisterImport.Indienst, Traeger.IndienstDat = DeisterImport.IndienstDat, Traeger.Ausdienst = DeisterImport.Ausdienst, Traeger.AusdienstDat = DeisterImport.AusdienstDat, Traeger.AbteilID = DeisterImport.AbteilID
WHEN NOT MATCHED THEN
  INSERT (VsaID, Status, Traeger, AbteilID, PersNr, Vorname, Nachname, Indienst, IndienstDat, Ausdienst, AusdienstDat)
  VALUES (DeisterImport.VsaID, DeisterImport.Status, DeisterImport.Traeger, DeisterImport.AbteilID, DeisterImport.PersNr, DeisterImport.Vorname, DeisterImport.Nachname, DeisterImport.Indienst, DeisterImport.IndienstDat, DeisterImport.Ausdienst, DeisterImport.AusdienstDat);

GO

DROP TABLE __DeisterBHS;

GO