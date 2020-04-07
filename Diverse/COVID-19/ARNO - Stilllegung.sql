CREATE TABLE __ARNOVsaStandKonSichtbar (
  VsaID int,
  StandKonID int,
  SichtbarID int
);

CREATE TABLE __ARNOTourenSichtbar (
  TourenID int,
  SichtbarID int
);

--SELECT Kunden.KdNr, Kunden.SuchCode, Standort.Bez AS Haupstandort, Vsa.VsaNr, Vsa.Bez AS Vsa, StandKon.StandKonBez, Sichtbar.Bez AS Sichtbarkeit
UPDATE Vsa SET StandKonID = 201, SichtbarID = 2
OUTPUT deleted.ID AS VsaID, deleted.StandKonID, deleted.SichtbarID
INTO __ARNOVsaStandKonSichtbar
FROM Vsa
JOIN Sichtbar ON Vsa.SichtbarID = Sichtbar.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN KdBer ON KdBer.KundenID = Kunden.ID
JOIN StandKon ON Vsa.StandKonID = StandKon.ID
JOIN StandBer ON StandBer.StandKonID = StandKon.ID
JOIN VsaBer ON VsaBer.VsaID = Vsa.ID AND KdBer.BereichID = StandBer.BereichID
WHERE StandBer.ProduktionID = (SELECT ID FROM Standort WHERE SuchCode = N'ARNO')
  AND Kunden.[Status] = N'A'
  AND Vsa.[Status] = N'A';

UPDATE Touren SET SichtbarID = 2
OUTPUT deleted.ID AS TourenID, deleted.SichtbarID
INTO __ARNOTourenSichtbar
FROM Touren
WHERE EXISTS (
  SELECT VsaTour.*
  FROM VsaTour
  WHERE VsaTour.TourenID = Touren.ID
    AND VsaTour.VsaID IN (SELECT VsaID FROM __ARNOVsaStandKonSichtbar)
);