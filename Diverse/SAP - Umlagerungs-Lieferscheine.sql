SELECT DISTINCT LsKo.LsNr, LsKo.[Status], LsKo.Referenz, LsKo.Memo, LsPoLagerart.LagerArt AS [abgebende Lagerart], LsPoFirma.SuchCode AS [abgebende Firma], BKo.BestNr AS [interne Bestellung], BKoLagerart.LagerArt AS [empfangende Lagerart], BKoFirma.SuchCode AS [empfangende Firma], CAST(IIF(LsPoFirma.ID != BKoFirma.ID, 1, 0) AS bit) AS [für SAP relevant], CAST(LsKo.SentToSAP AS bit) AS [an SAP übertragen]
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Lagerart AS LsPoLagerart ON LsPo.LagerArtID = LsPoLagerart.ID
JOIN Firma AS LsPoFirma ON LsPoLagerart.FirmaID = LsPoFirma.ID
JOIN BKo ON N'INTERN_' + CAST(BKo.BestNr AS nvarchar) = LsKo.Referenz
JOIN Lagerart AS BKoLagerart ON BKo.LagerArtID = BKoLagerart.ID
JOIN Firma AS BKoFirma ON BKoLagerart.FirmaID = BKoFirma.ID
WHERE LsKo.LsNr IN (49236898, 49236901, 49236904, 49236914, 49236918, 49236923, 49236926, 49236932, 49236937, 49236941);

GO