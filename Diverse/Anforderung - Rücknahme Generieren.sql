DECLARE @AnfReset TABLE (
  AnfPoID int,
  AnfKoID int,
  VsaID int
);

DECLARE @AnfDelete TABLE (
  AnfKoID int
);

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'KALLNI');
DECLARE @generatetime datetime2 = DATEADD(hour, -1, GETDATE());

WITH OldGeneratedDate AS (
  SELECT ChgLog.TableID AS VsaID, MIN(CAST(ChgLog.OldValue AS date)) AS OldValue
  FROM ChgLog
  WHERE ChgLog.TableName = N'VSA'
    AND ChgLog.FieldName = N'VsaAnfBis'
    AND ChgLog.AnlageUserID_ = @userid
    AND ChgLog.[Timestamp] > @generatetime
    AND NOT EXISTS (
      SELECT c.*
      FROM ChgLog c
      WHERE c.TableName = ChgLog.TableName
        AND c.FieldName = ChgLog.FieldName
        AND c.TableID = ChgLog.TableID
        AND c.ID > ChgLog.ID
        AND c.AnlageUserID_ != ChgLog.AnlageUserID_
    )
  GROUP BY ChgLog.TableID
)
INSERT INTO @AnfReset
SELECT AnfPo.ID AS AnfPoID, AnfPo.AnfKoID, AnfKo.VsaID
FROM AnfPo
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN Vsa ON AnfKo.VsaID = Vsa.ID
JOIN ServType ON Vsa.ServTypeID = ServType.ID
JOIN VsaAnf ON VsaAnf.KdArtiID = AnfPo.KdArtiID AND VsaAnf.VsaID = AnfKo.VsaID AND VsaAnf.ArtGroeID = AnfPo.ArtGroeID
WHERE AnfKo.LieferDatum > CAST(@generatetime AS date)
  AND UPPER(VsaAnf.Art) <> N'M'
  AND AnfKo.[Status] < N'I'
  AND (AnfKo.AnlageUserID_ = @userid OR AnfPo.UserID_ = @userid)
  AND NOT EXISTS (
    SELECT Scans.*
    FROM Scans
    WHERE Scans.EingAnfPoID = AnfPo.ID
  )
  AND NOT EXISTS (
    SELECT a.*
    FROM AnfPo a
    WHERE a.NachholAnfPoID = AnfPo.ID
  )
  AND EXISTS (
    SELECT OldGeneratedDate.*
    FROM OldGeneratedDate
    WHERE OldGeneratedDate.VsaID = Vsa.ID
  );

UPDATE AnfPo SET AnfPo.Angefordert = 0
WHERE AnfPo.ID IN (SELECT AnfPoID FROM @AnfReset)
  AND AnfPo.Angefordert != 0;

INSERT INTO @AnfDelete
SELECT AnfKo.ID
FROM AnfKo
WHERE AnfKo.ID IN (SELECT AnfKoID FROM @AnfReset)
  AND NOT EXISTS (
    SELECT AnfPo.*
    FROM AnfPo
    WHERE AnfPo.AnfKoID = AnfKo.ID
      AND AnfPo.Angefordert != 0
  )
  AND NOT EXISTS (
    SELECT AnfPo.*
    FROM AnfPo
    WHERE AnfPo.AnfKoID = AnfKo.ID
      AND EXISTS (
        SELECT a.*
        FROM AnfPo a
        WHERE a.NachholAnfPoID = AnfPo.ID
      )
  )
  AND NOT EXISTS (
    SELECT Scans.*
    FROM Scans
    JOIN AnfPo ON Scans.EingAnfPoID = AnfPo.ID
    WHERE AnfPo.AnfKoID = AnfKo.ID
  );

BEGIN TRANSACTION;
  DELETE FROM AnfPo WHERE AnfKoID IN (SELECT AnfKoID FROM @AnfDelete);
  DELETE FROM AnfKo WHERE ID IN (SELECT AnfKoID FROM @AnfDelete);
COMMIT;

WITH OldGeneratedDate AS (
  SELECT ChgLog.TableID AS VsaID, MIN(CAST(ChgLog.OldValue AS date)) AS OldValue
  FROM ChgLog
  WHERE ChgLog.TableName = N'VSA'
    AND ChgLog.FieldName = N'VsaAnfBis'
    AND ChgLog.AnlageUserID_ = @userid
    AND ChgLog.[Timestamp] > @generatetime
    AND NOT EXISTS (
      SELECT c.*
      FROM ChgLog c
      WHERE c.TableName = ChgLog.TableName
        AND c.FieldName = ChgLog.FieldName
        AND c.TableID = ChgLog.TableID
        AND c.ID > ChgLog.ID
        AND c.AnlageUserID_ != ChgLog.AnlageUserID_
    )
  GROUP BY ChgLog.TableID
)
UPDATE Vsa SET VsaAnfBis = OldGeneratedDate.OldValue
FROM OldGeneratedDate, Vsa
WHERE OldGeneratedDate.VsaID = Vsa.ID
  AND Vsa.VsaAnfBis != OldGeneratedDate.OldValue;