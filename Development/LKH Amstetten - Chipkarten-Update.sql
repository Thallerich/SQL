DECLARE @vsaid int;

SELECT @vsaid = Vsa.ID
FROM Vsa
WHERE Vsa.RentomatID = 62;

SELECT Traeger.ID AS TraegerID, Traeger.Nachname, Traeger.Vorname, Traeger.PersNr, _LKHAmstettenBKS.PersNr AS PersNr_Neu, Traeger.ChipSerienNummer, Traeger.RentomatKarte, _LKHAmstettenBKS.KartenID AS KarteNeu
FROM Traeger
JOIN _LKHAmstettenBKS ON SUBSTRING(Traeger.PersNr, PATINDEX('%[^0]%', Traeger.PersNr), 20) = _LKHAmstettenBKS.PersNr COLLATE Latin1_General_CS_AS
WHERE Traeger.VsaID = @vsaid
  AND Traeger.Status = N'A';

/* UPDATE Traeger SET RentomatKarte = _LKHAmstettenBKS.KartenID COLLATE Latin1_General_CS_AS
FROM Traeger
JOIN _LKHAmstettenBKS ON SUBSTRING(Traeger.PersNr, PATINDEX('%[^0]%', Traeger.PersNr), 20) = _LKHAmstettenBKS.PersNr COLLATE Latin1_General_CS_AS
WHERE Traeger.VsaID = @vsaid
  AND Traeger.Status = N'A'; */