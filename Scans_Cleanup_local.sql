USE Scans;

DECLARE @dowork bit;
SET @dowork = 1;

WHILE @dowork = 1
BEGIN
  BEGIN TRANSACTION;

  DELETE FROM Scans
  WHERE ID IN (
    SELECT TOP 100000 Scans.ID
    FROM Scans
    WHERE NOT EXISTS (
      SELECT TEILE.ID
      FROM TEILE
      WHERE TEILE.ID = Scans.TeileID
    )
  );

  IF @@ROWCOUNT > 0 SET @dowork = 1 ELSE SET @dowork = 0;

  COMMIT;
END;

SELECT COUNT(*) FROM Scans;

-- 550.676.060 Rows before delete