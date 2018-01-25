SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, KdArti.WaschPreis, IIF(FakFreq.FakPerID <> -1, KdArti.PeriodenPreis, KdArti.LeasingPreis) AS LeasingPreis, KdArti.KundenID
FROM KdArti
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN FakFreq ON KdBer.FakFreqID = FakFreq.ID
JOIN [Status] ON KdArti.[Status] = [Status].[Status] AND [Status].Tabelle = N'KDARTI'
WHERE KdArti.KundenID = $1$
  AND Status.ID IN ($2$)
ORDER BY Artikelbezeichnung ASC;