USE dbSystem;
GO

UPDATE TabField SET [Type] = N'W'
FROM TabField
JOIN TabName ON TabField.TabNameID = TabName.ID
WHERE TabName.TabName = N'RECHKO'
  AND TabField.Name = N'MemoFuss'
  AND TabField.[Type] = N'M';

GO