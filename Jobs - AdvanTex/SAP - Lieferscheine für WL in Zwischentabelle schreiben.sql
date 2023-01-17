IF OBJECT_ID(N'__LsInKalk') IS NOT NULL
  TRUNCATE TABLE __LsInKalk;
ELSE
  CREATE TABLE __LsInKalk (
    ID int
  );

DROP TABLE IF EXISTS #InKalkLS;

CREATE TABLE #InKalkLS (
  ID int PRIMARY KEY NOT NULL,
  VsaID int NOT NULL
);

INSERT INTO #InKalkLS (ID, VsaID)
SELECT LsKo.ID, LsKo.VsaID
FROM LsKo
WHERE LsKo.[Status] >= N'Q'
  AND LsKo.SentToSAP = 0
  AND LsKo.InternKalkFix = 1
  AND (LEFT(LsKo.Referenz, 7) != N'INTERN_' OR LsKo.Referenz IS NULL) /* Umlagerungs-LS ausnehmen, diese werden vom Modul SAPSENDSTOCKTRANSACTION übertragen */
  AND NOT EXISTS (
    SELECT LsPo.*
    FROM LsPo
    WHERE LsPo.LsKoID = LsKo.ID
      AND LsPo.ProduktionID = (SELECT ID FROM Standort WHERE SuchCode = N'SMZL')
  )
;

INSERT INTO __LsInKalk (ID)
SELECT LsKo.ID
FROM #InKalkLS LsKo
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
WHERE (
    (Firma.SuchCode = N'FA14' AND KdGf.KurzBez IN (N'MED', N'GAST', N'JOB', N'SAEU', N'BM', N'RT', N'MIC'))
    OR
    (Firma.SuchCode IN (N'SMP', N'SMKR', N'SMSK', N'SMRO', N'BUDA', N'SMRS', N'SMSL',N'SMHR'))
  );