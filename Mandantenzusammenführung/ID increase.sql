DECLARE @MaxID_Woz int;

SET @MaxID_Woz = (
  SELECT MAX(ID)
  FROM [ATENADVANTEX01\ADVANTEX].Wozabal.dbo.LogDel
);

ALTER TABLE LogDel DISABLE TRIGGER LastModified_LogDel_UPDATE;
UPDATE LogDel SET LogDel.ID = LogDel.ID + @MaxID_Woz + 1 WHERE LogDel.ID > 0;
ALTER TABLE LogDel ENABLE TRIGGER LastModified_LogDel_UPDATE;

SELECT * FROM LogDel;

/*

SELECT sysobjects.name AS Trigger_Name, sys.tables.name AS Table_Name, OBJECTPROPERTY( id, 'ExecIsUpdateTrigger') AS UpdateTrigger
FROM sysobjects
JOIN sys.tables ON sysobjects.parent_obj = sys.tables.object_id
WHERE sysobjects.type = N'TR'
  AND sys.tables.name = N'LogDel';

*/