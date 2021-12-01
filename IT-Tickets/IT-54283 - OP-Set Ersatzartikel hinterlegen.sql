DECLARE @inhaltid int = (SELECT ID FROM Artikel WHERE ArtikelNr = N'P71DXL');
DECLARE @ersatzid int = (SELECT ID FROM Artikel WHERE ArtikelNr = N'1298P71DXL00'); 

BEGIN TRANSACTION;

  UPDATE OPSets SET Artikel2ID = @ersatzid
  FROM OPSets
  WHERE OPSets.Artikel1ID = @inhaltid
    AND OPSets.Artikel2ID = -1
    AND NOT EXISTS (
      SELECT o.*
      FROM OPSets o
      WHERE o.ID = OPSets.ID
        AND (o.Artikel3ID = @ersatzid OR o.Artikel4ID = @ersatzid AND o.Artikel5ID = @ersatzid)
    );

  UPDATE OPSets SET Artikel3ID = @ersatzid
  FROM OPSets
  WHERE OPSets.Artikel1ID = @inhaltid
    AND OPSets.Artikel2ID > 0
    AND OPSets.Artikel3ID = -1
    AND NOT EXISTS (
      SELECT o.*
      FROM OPSets o
      WHERE o.ID = OPSets.ID
        AND (o.Artikel2ID = @ersatzid OR o.Artikel4ID = @ersatzid AND o.Artikel5ID = @ersatzid)
    );

  UPDATE OPSets SET Artikel4ID = @ersatzid
  FROM OPSets
  WHERE OPSets.Artikel1ID = @inhaltid
    AND OPSets.Artikel4ID = -1
    AND OPSets.Artikel2ID > 0
    AND OPSets.Artikel3ID > 0
    AND NOT EXISTS (
      SELECT o.*
      FROM OPSets o
      WHERE o.ID = OPSets.ID
        AND (o.Artikel2ID = @ersatzid OR o.Artikel3ID = @ersatzid AND o.Artikel5ID = @ersatzid)
    );

  UPDATE OPSets SET Artikel5ID = @ersatzid
  FROM OPSets
  WHERE OPSets.Artikel1ID = @inhaltid
    AND OPSets.Artikel5ID = -1
    AND OPSets.Artikel2ID > 0
    AND OPSets.Artikel3ID > 0
    AND OPSets.Artikel4ID > 0
    AND NOT EXISTS (
      SELECT o.*
      FROM OPSets o
      WHERE o.ID = OPSets.ID
        AND (o.Artikel2ID = @ersatzid OR o.Artikel3ID = @ersatzid AND o.Artikel4ID = @ersatzid)
    );

COMMIT TRANSACTION;
-- ROLLBACK TRANSACTION;