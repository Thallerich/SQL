DECLARE @RPoKontoU TABLE (
  RPoKontoID int,
  SGF nchar(4),
  Kostentraeger nchar(4)
);

INSERT INTO @RPoKontoU
SELECT RPoKonto.ID AS RPoKontoID, KdGf.KurzBez AS SGF, Kostentraeger = 
  CASE KdGf.KurzBez
    WHEN N'MED' THEN N'2400'
    WHEN N'GAST' THEN N'1100'
    WHEN N'JOB' THEN N'1400'
  END
FROM RPoKonto
JOIN KdGf ON RPoKonto.KdGfID = KdGf.ID
JOIN ArtGru ON RPoKonto.ArtGruID = ArtGru.ID
JOIN Bereich ON RPoKonto.BereichID = Bereich.ID
WHERE RPoKonto.FirmaID = (SELECT ID FROM Firma WHERE SuchCode = N'UKLU')
  AND RPoKonto.BereichID NOT IN (SELECT ID FROM Bereich WHERE Bereich.BereichBez IN (N'Wäschelogistik', N'Flachwäschelogistik'))
  AND RPoKonto.ArtGruID IN (SELECT ID FROM ArtGru WHERE ArtGruBez IN (N'Wäschelogistik', N'Wäschesack Bew'))
  AND RPoKonto.AbwKostenstelle = N'2800';

UPDATE RPoKonto SET RPoKonto.AbwKostenstelle = u.Kostentraeger
FROM RPoKonto
JOIN @RPoKontoU AS u ON u.RPoKontoID = RPoKonto.ID;