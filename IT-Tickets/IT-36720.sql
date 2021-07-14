DECLARE @ServiceMaID_UKLU int = (SELECT ID FROM Mitarbei WHERE Mitarbei.MaNr = N'UKLU5001');
DECLARE @ServiceMaID_GRAZ int = (SELECT ID FROM Mitarbei WHERE Mitarbei.MaNr = N'GRAZ5001');

DECLARE @KdBerUpdate TABLE (
  KdBerID int,
  ServiceID int
);

--SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Standort.SuchCode AS Hauptstandort, Bereich.Bereich, Mitarbei.Name AS Kundenservice
UPDATE KdBer SET ServiceID = 
  CASE Standort.SuchCode
    WHEN N'UKLU' THEN @ServiceMaID_UKLU
    WHEN N'GRAZ' THEN @ServiceMaID_GRAZ
  END
OUTPUT inserted.ID, inserted.ServiceID
INTO @KdBerUpdate
FROM KdBer
JOIN Kunden ON KdBer.KundenID = Kunden.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
WHERE Standort.SuchCode IN (N'UKLU', N'GRAZ')
  AND Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1
  AND NOT EXISTS (
    SELECT Vsa.*
    FROM Vsa
    JOIN StandKon ON Vsa.StandKonID = StandKon.ID
    WHERE Vsa.KundenID = Kunden.ID
      AND StandKon.ID NOT IN (201, 206, 227, 271, 313, 314, 315, 317)
  );

UPDATE VsaBer SET VsaBer.ServiceID = KdBerUpdate.ServiceID
FROM VsaBer
JOIN @KdBerUpdate AS KdBerUpdate ON KdBerUpdate.KdBerID = VsaBer.KdBerID;