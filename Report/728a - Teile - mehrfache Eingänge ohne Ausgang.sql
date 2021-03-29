SELECT Teile.Barcode, Teile.Eingang1, Teile.Eingang2, Teile.Eingang3, Teile.Ausgang1, Artikel.ArtikelNr AS [Artikel-Nr.], Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Traeger.Traeger AS [Träger-Nr.], Traeger.Vorname, Traeger.Nachname, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Kunden.Kdnr, Kunden.SuchCode, Produktion.SuchCode AS Produktion
FROM Teile
JOIN Traeger ON Teile.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ArtGroe ON Teile.ArtGroeID = ArtGroe.ID
JOIN KdArti ON Teile.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = Bereich.ID
JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID
WHERE Teile.Eingang2 > Teile.Ausgang1
  AND Teile.Status = N'Q'
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
  AND Teile.AltenheimModus = 0
  AND Vsa.StandKonID IN ($1$)
ORDER BY Kunden.KdNr, VsaNr, Traeger.Nachname;