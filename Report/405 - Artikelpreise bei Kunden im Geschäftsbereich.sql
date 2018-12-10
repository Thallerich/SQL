SELECT KdGf.KdGfBez$LAN$ AS Geschäftsbereich, Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr AS Artikelnummer, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, IIF(FakPer.AnzWochen <> 1, KdArti.PeriodenPreis, KdArti.LeasingPreis) AS Leasing, KdArti.WaschPreis AS Bearbeitung, KdArti.SonderPreis AS [Sonderpreis]
FROM KdArti
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN FakFreq ON KdBer.FakFreqID = FakFreq.ID
JOIN FakPer ON FakFreq.FakPerID = FakPer.ID
WHERE KdGf.ID IN ($1$)