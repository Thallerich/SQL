SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, KdGf.KurzBez AS Geschäftsbereich, Holding.Holding, [Zone].ZonenCode, Branche.BrancheBez AS Branche, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, PeKo.Bez AS Preiserhöhung, PeKo.WirksamDatum AS [Wirksam ab], PeKo.DurchfuehrungsDatum AS [durchgeführt am], Mitarbei.Name AS [durchgeführt von], PePo.PeProzent AS [Prozent erhöht], KdArti.WaschPreis AS [Bearbeitungspreis aktuell], KdArti.LeasPreis AS [Leasingpreis aktuell]
FROM PrArchiv
JOIN KdArti ON PrArchiv.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN Branche ON Kunden.BrancheID = Branche.ID
JOIN PeKo ON PrArchiv.PeKoID = PeKo.ID
JOIN Mitarbei ON PeKo.DurchfuehrungMitarbeiID = Mitarbei.ID
JOIN PePo ON PePo.PeKoID = PeKo.ID AND PePo.VertragID = KdBer.VertragID
WHERE PeKo.WirksamDatum >= CAST(N'2021-07-01' AS date)
  AND PeKo.Status = N'N'
  AND Kunden.FirmaID = (SELECT ID FROM Firma WHERE SuchCode = N'FA14');