SELECT Kunden.Kdnr, Kunden.Suchcode as Kunde, Holding.Holding, Traeger.Nachname, Traeger.Vorname, Status.StatusBez$LAN$ AS Statusbezeichnung, Teile.Barcode, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Teile.Anlage_ AS Angelegt_am, CreateMitarbei.UserName AS Angelegt_von, Teile.Update_ AS Update_am, UpdateMitarbei.UserName AS Update_von
FROM Teile
JOIN ArtGroe ON Teile.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Traeger ON Teile.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN [Status] ON Teile.Status = [Status].[Status] AND [Status].Tabelle = N'TEILE'
JOIN Mitarbei AS CreateMitarbei ON Teile.AnlageUserID_ = CreateMitarbei.ID
JOIN Mitarbei AS UpdateMitarbei ON Teile.UserID_ = UpdateMitarbei.ID
WHERE Teile.Anlage_ > CAST(N'01.04.2013 00:00:00' AS datetime)
  AND Artikel.BereichID = 100
  AND Status.ID IN ($2$)
  AND Kunden.KdGfID IN ($1$);