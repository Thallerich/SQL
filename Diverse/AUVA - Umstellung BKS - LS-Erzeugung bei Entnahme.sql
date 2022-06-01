DECLARE @LsKoAUVA TABLE (
  LsKoID int PRIMARY KEY
);

--SELECT DISTINCT LsKo.LsNr, LsKo.Datum, LsKo.Status, LsKo.LsKoArtID, LsKoArt.LsKoArtBez, Actions.ActionsBez, Kunden.KdNr, Kunden.SuchCode, Rentomat.LsKoArtScanOutID
INSERT INTO @LsKoAUVA (LsKoID)
SELECT DISTINCT LsKo.ID
FROM LsKo
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Rentomat ON Vsa.RentomatID = Rentomat.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN LsKoArt ON LsKo.LsKoArtID = LsKoArt.ID
JOIN LsPo ON LsPo.LsKoID = LsKo.ID
JOIN Scans ON Scans.LsPoID = LsPo.ID
JOIN Actions ON Scans.ActionsID = Actions.ID
WHERE Rentomat.SchrankNr IS NOT NULL
  AND LsKo.Datum >= N'2022-06-01'
  AND Scans.LsPoID > 0
  AND Rentomat.ID != 42;

BEGIN TRANSACTION;

  UPDATE LsKo SET LsKoArtID = 5027 WHERE ID IN (SELECT LsKoID FROM @LsKoAUVA);

  UPDATE LsPo SET Kostenlos = 1 WHERE LsKoID IN (SELECT LsKoID FROM @LsKoAUVA);

COMMIT;