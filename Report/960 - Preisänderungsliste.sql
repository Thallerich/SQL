SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Standort.Bez AS Haupstandort, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, KdArti.Variante, Status.StatusBez AS [Kundenartikel-Status], PrArchiv.Datum AS [Änderung effektiv ab], KdArti.WaschPreis AS [Bearbeitung aktuell], KdArti.LeasingPreis AS [Leasing aktuell], KdArti.PeriodenPreis AS [Periodenpreis aktuell], ISNULL(PeKo.Bez, N'') AS Preiserhöhung, ISNULL(Mitarbei.Name, N'') AS [PE-Durchführungs-Mitarbeiter], KdArti.ID AS KdArtiID
FROM PrArchiv
JOIN KdArti ON PrArchiv.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN Status ON KdArti.Status = Status.Status AND Status.Tabelle = N'KDARTI'
LEFT OUTER JOIN PeKo ON PrArchiv.PeKoID = PeKo.ID AND PrArchiv.PeKoID > 0
LEFT OUTER JOIN Mitarbei ON PeKo.DurchfuehrungMitarbeiID = Mitarbei.ID
WHERE PrArchiv.Datum BETWEEN $1$ AND $2$
  AND Kunden.KdGfID IN ($4$)
  AND Kunden.FirmaID IN ($3$);