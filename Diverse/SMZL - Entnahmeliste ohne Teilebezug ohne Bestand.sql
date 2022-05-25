DECLARE @EntnList TABLE (
  EntnListID int PRIMARY KEY CLUSTERED
);

INSERT INTO @EntnList (EntnListID)
VALUES (2954459), (2954438);

BEGIN TRANSACTION;
  UPDATE EntnPo SET EntnahmeMenge = EntnPo.Menge
  WHERE EntnPo.EntnKoID IN (SELECT EntnListID FROM @EntnList);

  UPDATE EntnKo SET [Status] = N'S'
  WHERE EntnKo.ID IN (SELECT EntnListID FROM @EntnList);
COMMIT;

DECLARE @AuftragReboot TABLE (
  AuftragID int PRIMARY KEY CLUSTERED
);

UPDATE Auftrag SET [Status] = N'F'
OUTPUT inserted.ID INTO @AuftragReboot (AuftragID)
WHERE Auftrag.ID IN (
  SELECT EntnKo.AuftragID
  FROM EntnKo
  WHERE EntnKo.ID IN (SELECT EntnListID FROM @EntnList)
);

SELECT N'AUFTRAGCLOSE;' + CAST(AuftragID AS nvarchar) AS ModuleCall
FROM @AuftragReboot;