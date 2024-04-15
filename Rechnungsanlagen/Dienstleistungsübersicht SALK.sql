SELECT IIF(ArtGru.Gruppe IN (N'OPK', N'OPS') OR (Kunden.KdNr = 19023 AND Artikel.ArtikelNr = N'24X7'), REPLACE(RechPo.Bez, N'Berufsbekleidung', N'Bereichsbekleidung'), RechPo.Bez) AS Positionsbezeichnung, RechKo.RechNr, RechKo.Debitor, RechKo.EffektivBis, RechKo.RechDat, SUM(RechPo.GPreis) AS Positionssumme
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGru ON RechPo.ArtGruID = ArtGru.ID
WHERE RechKo.ID = $RECHKOID$
GROUP BY IIF(ArtGru.Gruppe IN (N'OPK', N'OPS') OR (Kunden.KdNr = 19023 AND Artikel.ArtikelNr = N'24X7'), REPLACE(RechPo.Bez, N'Berufsbekleidung', N'Bereichsbekleidung'), RechPo.Bez), RechKo.RechNr, RechKo.Debitor, RechKo.EffektivBis, RechKo.RechDat;