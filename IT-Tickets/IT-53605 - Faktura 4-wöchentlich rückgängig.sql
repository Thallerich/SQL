UPDATE AbtKdArW SET RechPoID = -1
WHERE RechPoID IN (
  SELECT RechPo.ID
  FROM RechPo
  JOIN RechKo ON RechPo.RechKoID = RechKoID
  WHERE RechPo.FakLaufID IN (48336, 48338)
    AND RechKo.RechNr < 0
);

DECLARE @LsNoFakt TABLE (
  LsKoID int
);

UPDATE LsPo SET RechPoID = -1
OUTPUT deleted.LsKoID INTO @LsNoFakt
WHERE RechPoID IN (
  SELECT RechPo.ID
  FROM RechPo
  JOIN RechKo ON RechPo.RechKoID = RechKoID
  WHERE RechPo.FakLaufID IN (48336, 48338)
    AND RechKo.RechNr < 0
);

UPDATE LsKo SET [Status] = N'Q'
WHERE ID IN (
  SELECT DISTINCT LsKoID
  FROM @LsNoFakt
);

DECLARE @RKoDel TABLE (
  RechKoID int
);

DELETE FROM RechPo
OUTPUT deleted.RechKoID INTO @RKoDel
WHERE ID IN (
  SELECT RechPo.ID
  FROM RechPo
  JOIN RechKo ON RechPo.RechKoID = RechKoID
  WHERE RechPo.FakLaufID IN (48336, 48338)
    AND RechKo.RechNr < 0
);

DECLARE @KundenChange TABLE (
  KundenID int
);

DELETE FROM RechKo
OUTPUT deleted.KundenID INTO @KundenChange
WHERE ID IN (
    SELECT DISTINCT RechKoID
    FROM @RKoDel
  )
  AND NOT EXISTS (
    SELECT RechPo.*
    FROM RechPo
    WHERE RechPo.RechKoID = RechKo.ID
  );

UPDATE KdBer SET FakBisDat = N'2021-10-10', FakVonDat = N'2021-09-13'
WHERE KdBer.KundenID IN (
    SELECT DISTINCT KundenID
    FROM @KundenChange
  )
  AND (KdBer.FakBisDat = N'2021-11-07' OR KdBer.FakBisDat = N'2021-11-08');

UPDATE BrLauf SET LetzterLauf = N'' WHERE ID = 22;