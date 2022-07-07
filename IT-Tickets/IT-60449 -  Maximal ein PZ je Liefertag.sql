DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

DECLARE @ChgLog TABLE (
  TableName nchar(8),
  TableID int,
  FieldName nchar(32),
  [Timestamp] datetime,
  MitarbeiID int,
  OldValue nchar(12),
  NewValue nchar(12)
);

BEGIN TRANSACTION;

  UPDATE Vsa SET AnfKoLiefDatSchliessen = 1
  OUTPUT N'VSA', inserted.ID, N'AnfKoLiefDatSchliessen', GETDATE(), @UserID, CAST(deleted.AnfKoLiefDatSchliessen AS nchar(1)), CAST(inserted.AnfKoLiefDatSchliessen AS nchar(1))
  INTO @ChgLog (TableName, TableID, FieldName, [Timestamp], MitarbeiID, OldValue, NewValue)
  FROM Vsa
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN KdGf ON Kunden.KdGFID = KdGf.ID
  JOIN Standort ON Kunden.StandortID = Standort.ID
  WHERE Standort.SuchCode IN (N'WOEN', N'WOLI')
    AND KdGf.KurzBez = N'MED'
    AND Vsa.AnfKoLiefDatSchliessen = 0
    AND Kunden.[Status] = N'A'
    AND Vsa.[Status] = N'A'
    AND EXISTS (
      SELECT VsaAnf.*
      FROM VsaAnf
      WHERE VsaAnf.VsaID = Vsa.ID
    );

  INSERT INTO ChgLog (TableName, TableID, FieldName, [Timestamp], MitarbeiID, OldValue, NewValue)
  SELECT TableName, TableID, FieldName, [Timestamp], MitarbeiID, OldValue, NewValue
  FROM @ChgLog;

COMMIT;