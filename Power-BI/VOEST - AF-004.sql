SELECT Kunden.KdNr, Vsa.VsaNr, Vsa.Bez AS VsaBezeichnung, Vsa.GebaeudeBez AS Abteilung, Vsa.Name2 AS Bereich, Abteil.Bez AS Kostenstelle, Traeger.Traeger AS TrägerNr, Traeger.PersNr AS Personalnummer, Traeger.Vorname, Traeger.Nachname, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, KdArti.VariantBez AS Verrechnungsart, ArtGroe.Groesse AS Größe, EinzHist.Barcode, CAST(EinzTeil.LastScanTime AS date) AS Ausgabedatum
FROM EinzHist
JOIN EinzTeil ON EinzHist.EinzTeilID = EinzTeil.ID
JOIN TraeArti ON EinzHist.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Traeger ParentTraeger ON Traeger.ParentTraegerID = ParentTraeger.ID
JOIN Vsa ON ParentTraeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Abteil ON ParentTraeger.AbteilID = Abteil.ID
WHERE EinzHist.EinzHistTyp = 1
  AND EinzHist.IsCurrEinzHist = 1
  AND EinzHist.PoolFkt = 0
  AND EinzHist.[Status] BETWEEN N'Q' AND N'W'
  AND EinzHist.Einzug IS NULL
  AND Traeger.ParentTraegerID > 0
  AND Kunden.HoldingID IN (SELECT Holding.ID FROM Holding WHERE Holding.Holding IN (N'VOES', N'VOESAN', N'VOESLE'))
  AND Kunden.[Status] = N'A';