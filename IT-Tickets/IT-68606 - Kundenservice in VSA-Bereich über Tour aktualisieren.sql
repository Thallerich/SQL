DROP TABLE IF EXISTS #KSUpdate;

GO

CREATE TABLE #KSUpdate (
  VsaBerID int NOT NULL,
  ServiceID int NOT NULL
);

ALTER TABLE #KSUpdate
  ADD CONSTRAINT PK_KSUpdate PRIMARY KEY CLUSTERED (VsaBerID, ServiceID);

CREATE TABLE __IT68606_ServiceID (
  VsaBerID int,
  ServiceiD int
);

GO

INSERT INTO #KSUpdate (VsaBerID, ServiceID)
SELECT DISTINCT VsaBer.ID AS VsaBerID, Mitarbei.ID AS KundenserviceID
FROM VsaBer
JOIN VsaTour ON VsaTour.VsaID = VsaBer.VsaID AND VsaTour.KdBerID = VsaBer.KdBerID
JOIN Touren ON VsaTour.TourenID = Touren.ID
JOIN Vsa ON VsaBer.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Salesianer.dbo._IT68606 ON Touren.Tour = _IT68606.Tour
JOIN Mitarbei ON _IT68606.Kundenservice = Mitarbei.Name
WHERE VsaTour.BisDatum > CAST(GETDATE() AS date)
  AND Vsa.[Status] = N'A'
  AND Kunden.[Status] = N'A'
  AND Kunden.AdrArtID = 1
  AND VsaBer.ServiceID != Mitarbei.ID;

GO

UPDATE VsaBer SET ServiceID = KSUpdate.ServiceID
OUTPUT deleted.ID, deleted.ServiceID
INTO __IT68606_ServiceID (VsaBerID, ServiceiD)
FROM #KSUpdate KSUpdate
WHERE KSUpdate.VsaBerID = VsaBer.ID;

GO

SELECT Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Bez, Bereich.BereichBez
FROM (
  SELECT VsaBer.ID AS VsaBerID, COUNT(DISTINCT Mitarbei.ID) AS KundenserviceID
  FROM VsaBer
  JOIN VsaTour ON VsaTour.VsaID = VsaBer.VsaID AND VsaTour.KdBerID = VsaBer.KdBerID
  JOIN Touren ON VsaTour.TourenID = Touren.ID
  JOIN Vsa ON VsaBer.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN Salesianer.dbo._IT68606 ON Touren.Tour = _IT68606.Tour
  JOIN Mitarbei ON _IT68606.Kundenservice = Mitarbei.Name
  WHERE VsaTour.BisDatum > CAST(GETDATE() AS date)
    AND Vsa.[Status] = N'A'
    AND Kunden.[Status] = N'A'
    AND Kunden.AdrArtID = 1
  GROUP BY VsaBer.ID
  HAVING COUNT(DISTINCT Mitarbei.ID) > 1
) x
JOIN VsaBer ON x.VsaBerID = VsaBer.ID
JOIN KdBer ON VsaBer.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN Vsa ON VsaBer.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID;

GO