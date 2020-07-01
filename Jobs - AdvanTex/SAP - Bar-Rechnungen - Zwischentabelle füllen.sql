IF OBJECT_ID(N'dbo.__RechKoSofortSAP') IS NULL
BEGIN
  CREATE TABLE __RechKoSofortSAP (
    ID int
  );
END ELSE BEGIN
  TRUNCATE TABLE __RechKoSofortSAP;
END;

INSERT INTO __RechKoSofortSAP
SELECT RechKo.ID
FROM RechKo
JOIN Kunden ON RechKo.KundenID = Kunden.ID
WHERE RechKo.FibuExpID < 0
  AND Kunden.BarRech = 1
  AND RechKo.Status = N'F'
  AND RechKo.FirmaID = 5260;