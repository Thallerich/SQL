SELECT Scans.DateTime AS [Datum der Entnahme], EntnahmeTraeger.PersNr, EntnahmeTraeger.Traeger AS TraegerNr, EntnahmeTraeger.Nachname, EntnahmeTraeger.Vorname, Abteil.Abteilung AS KsSt, Abteil.Bez AS Kostenstelle, Teile.Barcode, Teile.RentomatChip AS Chipcode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Kunden.KdNr, Kunden.SuchCode AS Kunde
FROM Scans
JOIN LsPo ON Scans.LsPoID = LsPo.ID
JOIN RechPo ON LsPo.RechPoID = RechPo.ID
JOIN Teile ON Scans.TeileID = Teile.ID
JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON LsPo.ArtGroeID = ArtGroe.ID
JOIN Traeger AS EntnahmeTraeger ON Scans.LastPoolTraegerID = EntnahmeTraeger.ID
JOIN Abteil ON EntnahmeTraeger.AbteilID = Abteil.ID
WHERE RechPo.RechKoID = $RECHKOID$
  /* AND Traeger.RentoArtID IN (SELECT RentoArt.ID FROM RentoArt WHERE RentoArt.Code IN (N'S', N'T')) */ /* 2022-08-12 - Eigentlich falsch, einfach alles nehmen was aus Entnahmen auch auf die Rechnung lief, egal wo das Teil angelegt ist */
  AND Scans.ActionsID = 65;