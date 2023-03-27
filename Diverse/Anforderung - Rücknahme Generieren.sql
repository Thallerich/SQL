DECLARE @AnfReset TABLE (
  AnfPoID int,
  AnfKoID int,
  VsaID int
);

DECLARE @AnfDelete TABLE (
  AnfKoID int
);

WITH OldGeneratedDate AS (
  SELECT ChgLog.TableID AS VsaID, CAST(ChgLog.OldValue AS date) AS OldValue
  FROM ChgLog
  WHERE ChgLog.TableName = N'VSA'
    AND ChgLog.FieldName = N'VsaAnfBis'
    AND ChgLog.AnlageUserID_ = 9015291
    AND ChgLog.[Timestamp] > N'2023-03-27 12:00:00'
)
INSERT INTO @AnfReset
SELECT AnfPo.ID AS AnfPoID, AnfPo.AnfKoID, AnfKo.VsaID
FROM AnfPo
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN Vsa ON AnfKo.VsaID = Vsa.ID
JOIN ServType ON Vsa.ServTypeID = ServType.ID
JOIN VsaAnf ON VsaAnf.KdArtiID = AnfPo.KdArtiID AND VsaAnf.VsaID = AnfKo.VsaID AND VsaAnf.ArtGroeID = AnfPo.ArtGroeID
WHERE AnfKo.LieferDatum = N'2023-03-31'
  AND UPPER(VsaAnf.Art) <> N'M'
  AND AnfKo.[Status] < N'I'
  --AND AnfKo.ProduktionID IN (SELECT ID FROM Standort WHERE SuchCode = N'SAWR')
  AND (AnfKo.AnlageUserID_ = 9015291 OR AnfPo.UserID_ = 9015291)
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
  SELECT ChgLog.TableID AS VsaID, CAST(ChgLog.OldValue AS date) AS OldValue
  FROM ChgLog
  WHERE ChgLog.TableName = N'VSA'
    AND ChgLog.FieldName = N'VsaAnfBis'
    AND ChgLog.AnlageUserID_ = 9015291
    AND ChgLog.[Timestamp] > N'2023-03-27 12:00:00'
)
UPDATE Vsa SET VsaAnfBis = OldGeneratedDate.OldValue
FROM OldGeneratedDate
WHERE OldGeneratedDate.VsaID = Vsa.ID
  AND Vsa.ID IN (SELECT VsaID FROM @AnfReset);