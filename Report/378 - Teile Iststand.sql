SELECT Traeger.PersNr, Traeger.Nachname, Traeger.Vorname, Traeger.SchrankInfo AS [Schrank/Fach], Abteil.Bez AS Kostenstelle, Vsa.VsaNr, Vsa.Bez AS [VSA-Bezeichnung], EinzHist.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, KdArti.Variante, KdArti.VariantBez AS Variantenbezeichnung
FROM EinzHist
JOIN EinzTeil ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN TraeArti ON EinzHist.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
WHERE Vsa.KundenID = $ID$ 
	AND EinzHist.[Status] IN (N'Q', N'S')
  AND EinzHist.EinzHistTyp = 1
  AND EinzHist.PoolFkt = 0
  AND EinzTeil.AltenheimModus = 0;