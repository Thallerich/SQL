IF OBJECT_ID(N'__LsInKalk') IS NOT NULL
  TRUNCATE TABLE __LsInKalk;
ELSE
  CREATE TABLE __LsInKalk (
    ID int
  );

DECLARE @LsKo TABLE (
  ID int PRIMARY KEY,
  [Status] nchar(1),
  VsaID int
);

INSERT INTO @LsKo (ID, [Status], VsaID)
SELECT LsKo.ID, LsKo.[Status], LsKo.VsaID
FROM LsKo
WHERE LsKo.[Status] = N'Q'
  AND LsKo.SentToSAP = 0
  AND LsKo.InternKalkFix = 1
  AND LEFT(LsKo.Referenz, 7) != N'INTERN_' /* Umlagerungs-LS ausnehmen, diese werden vom Modul SAPSENDSTOCKTRANSACTION übertragen */
;

INSERT INTO __LsInKalk (ID)
SELECT LsKo.ID
FROM @LsKo LsKo
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
WHERE (
    (Firma.SuchCode = N'FA14' AND KdGf.KurzBez IN (N'MED', N'GAST', N'JOB', N'SAEU', N'BM', N'RT', N'MIC'))
    OR
    (Firma.SuchCode IN (N'SMP', N'SMKR', N'SMSK', N'SMRO', N'BUDA', N'SMRS', N'SMSL',N'SMHR'))
  );