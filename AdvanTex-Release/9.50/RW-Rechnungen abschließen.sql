UPDATE RechKo SET [Status] = N'B'
WHERE RechKo.Status = 'A'
  AND EXISTS (
    SELECT RechPo.*
    FROM RechPo
    WHERE RechPo.RechKoID = RechKo.ID
      AND RechPo.RPoTypeID = 3
  );