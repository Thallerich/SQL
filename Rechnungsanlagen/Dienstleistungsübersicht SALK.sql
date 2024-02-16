SELECT IIF(ArtGru.Gruppe = N'OPK', REPLACE(RechPo.Bez, N'Berufsbekleidung', N'Bereichsbekleidung'), RechPo.Bez) AS Positionsbezeichnung, RechKo.RechNr, RechKo.Debitor, RechKo.EffektivBis, RechKo.RechDat, SUM(RechPo.GPreis) AS Positionssumme
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
LEFT JOIN ArtGru ON RechPo.ArtGruID = ArtGru.ID
WHERE RechKo.ID = $RECHKOID$
GROUP BY IIF(ArtGru.Gruppe = N'OPK', REPLACE(RechPo.Bez, N'Berufsbekleidung', N'Bereichsbekleidung'), RechPo.Bez), RechKo.RechNr, RechKo.Debitor, RechKo.EffektivBis, RechKo.RechDat;