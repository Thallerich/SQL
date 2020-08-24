DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

INSERT INTO VsaTexte (KundenID, VsaID, TextArtID, Memo, VonDatum, BisDatum, AnlageUserID_, UserID_)
SELECT Vsa.KundenID, Vsa.ID AS VsaID, 2 AS TextArtID, N'ACHTUNG – unsere E-Mail Adresse ändert sich ab sofort auf mietwaesche@salesianer.com' AS Memo, CAST(GETDATE() AS date) AS VonDatum, N'2020-12-31' AS BisDatum, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Vsa.Status = N'A'
  AND Kunden.Status = N'A'
  AND EXISTS (
    SELECT VsaTour.*
    FROM VsaTour
    JOIN Touren ON VsaTour.TourenID = Touren.ID
    JOIN Standort AS Expedition ON Touren.ExpeditionID = Expedition.ID
    WHERE VsaTour.VsaID = Vsa.ID
      AND CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
      AND Expedition.SuchCode LIKE N'UKL%'
  );