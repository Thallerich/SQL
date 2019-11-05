SELECT Kunden.KdNr, Kunden.SuchCode AS [Kunden-Stichwort], Kunden.Name1, Kunden.Name2, Kunden.Name3, Vsa.VsaNr, Vsa.Bez AS VsaBez, Traeger.Traeger AS Bewohnernummer, Traeger.Nachname, Traeger.Vorname, Traeger.Geschlecht, Traeger.Indienst AS [Start-Woche], Traeger.Ausdienst AS [Abmelde-Woche], Traeger.PersNr AS Zimmernummer, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, WaschPrg.WaschPrg AS Waschprogramm, WaschPrg.WaschPrgBez AS [Waschprogramm-Bezeichnung], Teile.Barcode, Teile.RuecklaufK AS [Anzahl Wäschen], Teile.IndienstDat AS Erstanlage, Teile.Eingang1 AS [letzter Eingang], Teile.Ausgang1 AS [letzter Ausgang]
FROM Kunden
JOIN Vsa ON Vsa.KundenID = Kunden.ID
JOIN Traeger ON Traeger.VsaID = Vsa.ID
JOIN TraeArti ON TraeArti.TraegerID = Traeger.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN WaschPrg ON Artikel.WaschPrgID = WaschPrg.ID
JOIN Teile ON Teile.TraeArtiID = TraeArti.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
WHERE Traeger.Altenheim = 1
  AND Holding.Holding = N'AHA'