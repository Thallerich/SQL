DECLARE @ToDelete TABLE (ID int);

INSERT INTO @ToDelete
SELECT RechAdr.ID
FROM RechAdr
WHERE ID > 0
  AND NOT EXISTS (SELECT Abteil.* FROM Abteil WHERE Abteil.RechAdrID = RechAdr.ID)
  AND NOT EXISTS (SELECT RechKo.* FROM RechKo WHERE RechKo.RechAdrID = RechAdr.ID);

DELETE FROM RechAdr WHERE ID IN (SELECT ID FROM @ToDelete);