SELECT IIF(ArtGru.Gruppe IN (N'IK1', N'IK2', N'SH12', N'SH13', N'DRY'), N'Inko-Versorgung', IIF(RPoType.StatistikGruppe = N'Restwerte', RechPo.Bez, RPoType.RPoTypeBez$LAN$ + N' ' + Bereich.BereichBez$LAN$)) AS Positionsbezeichnung, RechKo.RechNr, RechKo.Debitor, RechKo.EffektivBis, RechKo.RechDat, SUM(RechPo.GPreis) AS Positionssumme
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Bereich ON RechPo.BereichID = Bereich.ID
JOIN RPoType ON RechPo.RPoTypeID = RPoType.ID
LEFT OUTER JOIN ArtGru ON RechPo.ArtGruID = ArtGru.ID
WHERE RechKo.ID = $RECHKOID$
GROUP BY IIF(ArtGru.Gruppe IN (N'IK1', N'IK2', N'SH12', N'SH13', N'DRY'), N'Inko-Versorgung', IIF(RPoType.StatistikGruppe = N'Restwerte', RechPo.Bez, RPoType.RPoTypeBez$LAN$ + N' ' + Bereich.BereichBez$LAN$)), RechKo.RechNr, RechKo.Debitor, RechKo.EffektivBis, RechKo.RechDat;