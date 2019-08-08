DECLARE @KontologikSMBU TABLE (
  BereichID int,
  ArtGruID int,
  BrancheID int,
  RPoTypeID int,
  FirmaID int,
  KdGfID int,
  MwStID int,
  Art nchar(1),
  Bez nvarchar(40),
  KontenID int,
  RKoTypeID int,
  AbwKostenstelle nchar(10)
);

INSERT INTO @KontologikSMBU
SELECT DISTINCT RPoKonto.BereichID, RPoKonto.ArtGruID, RPoKonto.BrancheID, RPoKonto.RPoTypeID, 5269 AS FirmaID, RPoKonto.KdGfID, 11 AS MwStID, RPoKonto.Art, N'automatisch angelegt - STHA 08.08.2019' AS Bez, RPoKonto.KontenID, RPoKonto.RKoTypeID, RPoKonto.AbwKostenstelle
FROM RPoKonto
WHERE RPoKonto.FirmaID = 5260
  AND RPoKonto.MWStID = 1;

/* UPDATE @KontologikSMBU SET AbwKostenstelle = N'1310' WHERE AbwKostenstelle = N'1100';
UPDATE @KontologikSMBU SET AbwKostenstelle = N'1310' WHERE AbwKostenstelle = N'1200';
UPDATE @KontologikSMBU SET AbwKostenstelle = N'1310' WHERE AbwKostenstelle = N'1300';
UPDATE @KontologikSMBU SET AbwKostenstelle = N'1338' WHERE AbwKostenstelle = N'1330';
UPDATE @KontologikSMBU SET AbwKostenstelle = N'1338' WHERE AbwKostenstelle = N'1331';
UPDATE @KontologikSMBU SET AbwKostenstelle = N'1338' WHERE AbwKostenstelle = N'1333';
UPDATE @KontologikSMBU SET AbwKostenstelle = N'1338' WHERE AbwKostenstelle = N'1334';
UPDATE @KontologikSMBU SET AbwKostenstelle = N'1310' WHERE AbwKostenstelle = N'1340'; */

/* SELECT RPoKonto.*
INTO __RPoKonto_SMBU_BMD
FROM RPoKonto
WHERE RPoKonto.FirmaID = 5256; */

DELETE FROM RPoKonto WHERE FirmaID = 5269;

INSERT INTO RPoKonto (BereichID, ArtGruID, BrancheID, RPoTypeID, FirmaID, KdGfID, MWStID, Art, Bez, KontenID, RKoTypeID, AbwKostenstelle)
SELECT * FROM @KontologikSMBU;