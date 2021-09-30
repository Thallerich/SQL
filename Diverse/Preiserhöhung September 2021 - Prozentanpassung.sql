DECLARE @PeProz TABLE (
  PeBez nvarchar(40) COLLATE Latin1_General_CS_AS,
  Proz numeric(18,4)
);

IF OBJECT_ID('__PePo20210930_1') IS NULL
  CREATE TABLE __PePo20210930_1 (
    PePoID int,
    PeProzent numeric(18,4)
  );

IF OBJECT_ID('__PeKo20210930_1') IS NULL
  CREATE TABLE __PeKo20210930_1 (
    PeKoID int,
    ProzVorschlag numeric(18, 4)
  );

INSERT INTO @PeProz
VALUES (N'A/OST/GAST/Jänner', 3.55), (N'A/OST/GAST/September', 4.95), (N'A/SÜD/GAST/Jänner', 3.55), (N'A/SÜD/GAST/September', 4.95), (N'A/WEST/GAST/Jänner', 3.55), (N'A/WEST/GAST/September', 4.95), (N'B/MITTE/JOB/Jänner', 4.18), (N'B/OST/GAST/Jänner', 3.55), (N'B/OST/GAST/September', 4.95), (N'B/OST/JOB/Jänner', 4.18), (N'B/SÜD/GAST/Jänner', 3.55), (N'B/SÜD/GAST/September', 4.95), (N'B/SÜD/JOB/Jänner', 4.18), (N'B/WEST/GAST/Jänner', 3.55), (N'B/WEST/GAST/September', 4.95), (N'B/WEST/JOB/Jänner', 4.18), (N'C/MITTE/JOB/Jänner', 6.18), (N'C/OST/GAST/September', 7.58), (N'C/OST/JOB/Jänner', 6.18), (N'C/SÜD/JOB/Jänner', 6.18), (N'C/WEST/GAST/September', 7.58), (N'D/Jänner', 6.18);

UPDATE PePo SET PePo.PeProzent = PeProz.Proz
OUTPUT inserted.ID, deleted.PeProzent
INTO __PePo20210930_1 (PePoID, PeProzent)
--SELECT PePo.ID AS PePoID, PePo.PeProzent, PePo.AnlageProzent, PeProz.ProzVorschlag
FROM PePo
JOIN PeKo ON PePo.PeKoID = PeKo.ID
JOIN @PeProz AS PeProz ON PeKo.Bez = PeProz.PeBez
WHERE PeKo.Status = N'C'
  AND PePo.AnlageProzent = PePo.PeProzent 
  AND PePo.KuendGruID < 0
  AND PePo.PeProzent != PeProz.Proz;

UPDATE PeKo SET PeKo.ProzVorschlag = PeProz.Proz
OUTPUT inserted.ID, deleted.ProzVorschlag
INTO __PeKo20210930_1 (PeKoID, ProzVorschlag)
--SELECT PeKo.ID AS PeKoID, PeKo.ProzVorschlag, PeProz.Proz
FROM PeKo
JOIN @PeProz AS PeProz ON PeKo.Bez = PeProz.PeBez
WHERE PeKo.Status = N'C'
  AND PeKo.ProzVorschlag != PeProz.Proz;