IF OBJECT_ID('__KdBerBackup') IS NULL
BEGIN
  CREATE TABLE __KdBerBackup (
    KdBerID int,
    BetreuerID int,
    Restored bit 
  );
END;

GO

SET CONTEXT_INFO 0x1; /* AdvanTex-Trigger für RepQueue deaktivieren */
GO

WITH ImportData AS (
  SELECT Kunden.ID AS KundenID, Kunden.KdNr, COALESCE(Mitarbei.ID, ErsatzMitarbei.ID, -1) AS MitarbeiID, COALESCE(Mitarbei.Name, ErsatzMitarbei.Name) AS [Name], _KdBetreuerImport.Betreuer
  FROM _KdBetreuerImport
  JOIN Kunden ON _KdBetreuerImport.KdNr = Kunden.KdNr
  LEFT JOIN Mitarbei ON _KdBetreuerImport.Betreuer = Mitarbei.Name AND Mitarbei.Betreuer = 1
  LEFT JOIN Mitarbei AS ErsatzMitarbei ON _KdBetreuerImport.Betreuer = ErsatzMitarbei.Name AND ErsatzMitarbei.Betreuer = 0
  WHERE _KdBetreuerImport.BKIsdone = 0
)
UPDATE KdBer SET BetreuerID = ImportData.MitarbeiID
OUTPUT deleted.ID, deleted.BetreuerID
INTO __KdBerBackup (KdBerID, BetreuerID)
FROM KdBer
JOIN Kunden ON KdBer.KundenID = Kunden.ID
JOIN ImportData ON ImportData.KundenID = Kunden.ID
WHERE KdBer.BetreuerID != ImportData.MitarbeiID

GO

SET CONTEXT_INFO 0x; /* AdvanTex-Trigger für RepQueue aktivieren */
GO


/* Restore those with multiple Betreuer */

SET CONTEXT_INFO 0x1; /* AdvanTex-Trigger für RepQueue deaktivieren */
GO

DECLARE @restored TABLE (
  KdBerID int
);

UPDATE KdBer SET BetreuerID = __KdBerBackup.BetreuerID
OUTPUT inserted.ID
INTO @restored
FROM __KdBerBackup
WHERE __KdBerBackup.KdBerID = KdBer.ID
  AND KdBer.ID IN (
    SELECT KdBer.ID
    FROM KdBer
    WHERE KundenID IN (
      SELECT Kunden.ID AS KundenID
      FROM Kunden
      WHERE EXISTS (
        SELECT 1
        FROM __KdBerBackup
        JOIN KdBer ON __KdBerBackup.KdBerID = KdBer.ID
        WHERE KdBer.KundenID = Kunden.ID
        GROUP BY KdBer.KundenID
        HAVING COUNT(DISTINCT __KdBerBackup.BetreuerID) > 1
      )
    )
);

UPDATE __KdBerBackup SET Restored = 1
WHERE KdBerID IN (SELECT KdBerID FROM @restored);

GO

SET CONTEXT_INFO 0x; /* AdvanTex-Trigger für RepQueue aktivieren */
GO