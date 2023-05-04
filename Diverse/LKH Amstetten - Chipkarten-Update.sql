DECLARE @vsaid int;

SELECT @vsaid = Vsa.ID
FROM Vsa
WHERE Vsa.RentomatID = 62;

/* SELECT Traeger.ID AS TraegerID, Traeger.Nachname, Traeger.Vorname, Traeger.PersNr, _LKAmstettenBKS.PersNr AS PersNr_Neu, Traeger.ChipSerienNummer, Traeger.RentomatKarte, _LKAmstettenBKS.RentomartKarte AS KarteNeu
FROM Traeger
JOIN _LKAmstettenBKS ON SUBSTRING(Traeger.PersNr, PATINDEX('%[^0]%', Traeger.PersNr), 20) = _LKAmstettenBKS.PersNr
WHERE Traeger.VsaID = @vsaid
  AND Traeger.Status = N'A'; */


UPDATE Traeger SET RentomatKarte = _LKAmstettenBKS.RentomartKarte
FROM Traeger
JOIN _LKAmstettenBKS ON SUBSTRING(Traeger.PersNr, PATINDEX('%[^0]%', Traeger.PersNr), 20) = _LKAmstettenBKS.PersNr 
WHERE Traeger.VsaID = @vsaid
  AND Traeger.Status = N'A';
