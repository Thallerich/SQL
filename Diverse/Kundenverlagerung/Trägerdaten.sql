SELECT Kunden.KdNr, Vsa.VsaNr, Traeger.Traeger, Traeger.Vorname, Traeger.Nachname, Traeger.PersNr, Abteil.Abteilung AS Kostenstelle, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, KdArti.Variante, ArtGroe.Groesse, Traeger.Titel
FROM TraeArti
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
WHERE Traeger.Altenheim = 0
  AND Traeger.Status <> N'I'
  AND Firma.SuchCode <> N'STX';