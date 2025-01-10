DECLARE @History TABLE (
  HistoryID int PRIMARY KEY
);

INSERT INTO @History (HistoryID)
SELECT History.ID
FROM History WITH (UPDLOCK)
WHERE History.HistKatID IN (
    SELECT HistKat.ID
    FROM HistKat
    WHERE HistKat.Reklamation = 1
  )
  AND History.HistUrsaID IN (
    SELECT HistUrsa.ID
    FROM HistUrsa
    WHERE (
          HistUrsa._ParentIntDepartmentID > 0
      AND HistUrsa._ParentQmDimensionID > 0
      AND HistUrsa.ID != -2
    )
    OR HistUrsa.ID = -1
  )
  AND (
    (
          History.TableName = N'KUNDEN'
      AND History.TableID IN (
        SELECT Kunden.ID
        FROM Kunden
        WHERE Kunden.StandortID IN (
          SELECT Standort.ID
          FROM Standort
          WHERE Standort.SuchCode IN (N'BUKA', N'SMKR', N'ORAD')
        )
      )
    )
    OR
    (
          History.TableName = N'VSA'
      AND History.TableID IN (
        SELECT Vsa.ID
        FROM Vsa
        WHERE Vsa.KundenID IN (
          SELECT Kunden.ID
          FROM Kunden
          WHERE Kunden.StandortID IN (
            SELECT Standort.ID
            FROM Standort
            WHERE Standort.SuchCode IN (N'BUKA', N'SMKR', N'ORAD')
          )
        )
      )
    )
    OR
    (
          History.TableName = N'TRAEGER'
      AND History.TableID IN (
        SELECT Traeger.ID
        FROM Traeger
        WHERE Traeger.VsaID IN (
          SELECT Vsa.ID
          FROM Vsa
          WHERE Vsa.KundenID IN (
            SELECT Kunden.ID
            FROM Kunden
            WHERE Kunden.StandortID IN (
              SELECT Standort.ID
              FROM Standort
              WHERE Standort.SuchCode IN (N'BUKA', N'SMKR', N'ORAD')
            )
          )
        )
      )
    )
  )
  AND History.[Status] = N'A'
  AND History.Anlage_ < N'2024-01-01 00:00:00.000';

UPDATE History SET [Status] = N'S'
WHERE History.ID IN (SELECT HistoryID FROM @History);