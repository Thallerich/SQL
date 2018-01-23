DECLARE @LsUpdate TABLE (
  LsKoID int,
  LsPoID int
);

INSERT INTO @LsUpdate
SELECT LsKo.ID AS LsKoID, LsPo.ID AS LsPoID
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.KdNr = 26020
  AND Vsa.VsaNr = 300
  AND LsKo.Datum <= CAST(GETDATE() AS date)
  AND LsPo.RechPoID = -1
  AND LsPo.Kostenlos = 0;

UPDATE LsPo SET LsPo.Kostenlos = 1, LsPo.RechPoID = -2
WHERE LsPo.ID IN (
  SELECT LsPoID FROM @LsUpdate
);

UPDATE LsKo SET Status = N'W'
WHERE LsKo.ID IN (
  SELECT DISTINCT LsKoID FROM @LsUpdate
);