DECLARE @LsPo TABLE (
  LsPoID int,
  LsKoID int
);

DECLARE @LsKoArtID int = (SELECT ID FROM LsKoArt WHERE Art = N'G');

INSERT INTO @LsPo (LsPoID, LsKoID)
SELECT DISTINCT LsPo.ID, LsKo.ID
FROM LsPo
JOIN Scans ON Scans.LsPoID = LsPo.ID
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Rentomat ON Vsa.RentomatID = Rentomat.ID
WHERE Rentomat.SchrankNr IS NOT NULL
  AND Rentomat.Interface = N'DCSvoll'
  AND LsKo.Status < N'W'
  AND LsPo.RechPoID = -1
  AND Scans.ActionsID != 65
  AND LsPo.Kostenlos = 0
  AND Holding.Holding = N'AUVA';

UPDATE LsKo SET LsKoArtID = @LsKoArtID
WHERE ID IN (
  SELECT LsKoID
  FROM @LsPo
);

UPDATE LsPo SET Kostenlos = 1
WHERE ID IN (
  SELECT LsPoID
  FROM @LsPo
);

UPDATE LsPo SET Kostenlos = 1
WHERE LsKoID IN (
    SELECT LsKoID
    FROM @LsPo
  )
  AND LsPo.Kostenlos = 0
  AND LsPo.Menge = 0;