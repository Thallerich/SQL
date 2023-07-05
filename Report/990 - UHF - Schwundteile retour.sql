SELECT Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, EinzTeil.Code AS Chipcode, RechKo.RechNr, RechKo.RechDat AS Rechnungsdatum, CAST(RechPo.Anlage_ AS date) AS [Erstell-Datum Rechnungsposition], EinzTeil.FirstScanAfterInvoice AS [Erster Scan nach Verrechnung], Kunden.RWGutschriftXTage AS [Gutschrift bis X Tage nach Verrechnung], CAST(IIF(Kunden.RWGutschriftXTage > 0 AND DATEADD(day, Kunden.RWGutschriftXTage, RechKo.RechDat) <= CAST(EinzTeil.FirstScanAfterInvoice AS date), 1, 0) AS bit) AS [wird gutgeschrieben]
FROM EinzTeil
JOIN RechPo ON EinzTeil.RechPoID = RechPo.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
WHERE EinzTeil.[Status] < N'W'
  AND EinzTeil.RechPoID > 0
  AND EinzTeil.FirstScanAfterInvoice IS NOT NULL
  AND RechPo.RPoTypeID = 23
  AND Kunden.ID IN ($2$);