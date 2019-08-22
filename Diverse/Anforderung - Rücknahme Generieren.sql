DECLARE @AnfReset TABLE (
  AnfPoID int,
  AnfKoID int,
  VsaID int
);

DECLARE @AnfDelete TABLE (
  AnfKoID int
);

INSERT INTO @AnfReset
SELECT AnfPo.ID AS AnfPoID, AnfPo.AnfKoID, AnfKo.VsaID
FROM AnfPo
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN Vsa ON AnfKo.VsaID = Vsa.ID
JOIN ServType ON Vsa.ServTypeID = ServType.ID
JOIN VsaAnf ON VsaAnf.KdArtiID = AnfPo.KdArtiID AND VsaAnf.VsaID = AnfKo.VsaID AND VsaAnf.ArtGroeID = AnfPo.ArtGroeID
WHERE ServType.Code <> N'LH'
  AND AnfKo.LieferDatum = N'2019-08-28'
  AND UPPER(VsaAnf.Art) <> N'M'
  AND AnfKo.[Status] < N'I'
  AND (AnfKo.AnlageUserID_ = 9012574 OR AnfPo.UserID_ = 9012574);

UPDATE AnfPo SET AnfPo.Angefordert = 0
WHERE AnfPo.ID IN (SELECT AnfPoID FROM @AnfReset)
  AND AnfPo.Angefordert <> 0;

INSERT INTO @AnfDelete
SELECT AnfKo.ID
FROM AnfKo
WHERE AnfKo.ID IN (SELECT AnfKoID FROM @AnfReset)
  AND NOT EXISTS (
    SELECT AnfPo.*
    FROM AnfPo
    WHERE AnfPo.AnfKoID = AnfKo.ID
      AND AnfPo.Angefordert <> 0
  );

DELETE FROM AnfPo WHERE AnfKoID IN (SELECT AnfKoID FROM @AnfDelete);
DELETE FROM AnfKo WHERE ID IN (SELECT AnfKoID FROM @AnfDelete);

UPDATE Vsa SET VsaAnfBis = N'2019-08-27'
WHERE Vsa.ID IN (SELECT VsaID FROM @AnfReset)
  AND Vsa.VsaAnfBis = N'2019-08-28';