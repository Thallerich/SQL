DECLARE @LsKo TABLE (
  LsKoID int PRIMARY KEY CLUSTERED
);

INSERT INTO @LsKo (LsKoID)
SELECT DISTINCT lsko.ID
FROM lsko
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE LsKo.[Status] = 'O'
  AND LsKo.Datum < N'2022-05-01'
  AND (Kunden.FirmaID = (SELECT ID FROM Firma WHERE SuchCode = N'FA14') OR Kunden.Status = N'I')
  AND LsKo.ID > 0;

BEGIN TRANSACTION;
  UPDATE LsKo SET [Status] = N'W' WHERE ID IN (SELECT LsKoID FROM @LsKo);
  UPDATE LsPo SET Prognose = 0 WHERE Prognose = 1 AND LsKoID IN (SELECT LsKoID FROM @LsKo);
  UPDATE LsPo SET RechPoID = -2 WHERE RechPoID = -1 AND LsKoID IN (SELECT LsKoID FROM @LsKo);
COMMIT;

SELECT LsPo.*
FROM LsPo
WHERE LsPo.LsKoID IN (SELECT LsKoID FROM @LsKo)
  AND LsPo.RechPoID = -1
  AND LsPo.Kostenlos = 0;

GO