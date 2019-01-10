DECLARE @BKTraeger TABLE (
  TraegerID int,
  PersNr nvarchar(10) COLLATE Latin1_General_CS_AS,
  RentomatKarte nvarchar(25) COLLATE Latin1_General_CS_AS,
  TraegerIDAlt int,
  RentoCodID int,
  RentomatKredit int,
  KdAusstaID int
);

INSERT INTO @BKTraeger (TraegerID, PersNr, RentomatKarte)
SELECT Traeger.ID AS TraegerID, Traeger.PersNr, Traeger.RentomatKarte
FROM Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.KdNr = 23041
  AND Vsa.RentomatID > 0
  AND Traeger.Anlage_ >= N'2019-01-10 08:00:00'
  AND Traeger.VormalsNr = N'BK'
  AND Traeger.RentoCodID < 0;

--SELECT Traeger.ID, Traeger.PersNr, Traeger.RentomatKarte, BKTraeger.RentomatKarte AS RKAktuell, Traeger.KdAusstaID, Traeger.RentoArtID, Traeger.RentoCodID
UPDATE @BKTraeger SET TraegerIDAlt = Traeger.ID, RentoCodID = Traeger.RentoCodID, RentomatKredit = Traeger.RentomatKredit, KdAusstaID = Traeger.KdAusstaID
FROM Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN @BKTraeger AS BKTraeger ON BKTraeger.PersNr = Traeger.PersNr AND BKTraeger.TraegerID <> Traeger.ID
WHERE Kunden.KdNr = 23041
  AND Vsa.RentomatID > 0;

INSERT INTO TraeArti (VsaID, TraegerID, ArtGroeID, KdArtiID)
SELECT Traeger.VsaID, BKTraeger.TraegerID, TraeArti.ArtGroeID, TraeArti.KdArtiID
FROM @BKTraeger AS BKTraeger
JOIN Traeger ON BKTraeger.TraegerIDAlt = Traeger.ID
JOIN TraeArti ON TraeArti.TraegerID = Traeger.ID
WHERE BKTraeger.TraegerIDAlt IS NOT NULL;

UPDATE Traeger SET Traeger.RentoCodID = BKTraeger.RentoCodID, Traeger.RentomatKredit = BKTraeger.RentomatKredit, Traeger.KdAusstaID = BKTraeger.KdAusstaID
FROM Traeger
JOIN @BKTraeger AS BKTraeger ON BKTraeger.TraegerID = Traeger.ID
WHERE BKTraeger.TraegerIDAlt IS NOT NULL;

SELECT Traeger.Traeger, Traeger.PersNr, Traeger.Nachname, Traeger.Vorname
FROM @BKTraeger AS BKTraeger
JOIN Traeger ON BKTraeger.TraegerID = Traeger.ID
WHERE BKTraeger.TraegerIDAlt IS NULL;