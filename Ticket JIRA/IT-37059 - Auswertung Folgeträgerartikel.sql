SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Traeger.Traeger, Traeger.Nachname, Traeger.Vorname, Vsa.VsaNr, Vsa.Bez AS VsaBezeichnung, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Artikel.ArtikelNr, Artikel.ArtikelBez, KdArti.Variante, ArtGroe.Groesse, TraeArti.Menge AS TrägerartikelMenge, FolgeArtikel.ArtikelNr AS FolgeartikelNr, FolgeArtikel.ArtikelBez AS Folgeartikelbezeichnung, FolgeKdArti.Variante AS FolgeartikelVariante, FolgeArtGroe.Groesse FolgeartikelGroesse, FolgeTraeArti.Menge AS FolgeartikelMenge
FROM TraeArti
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN TraeArti AS FolgeTraeArti ON TraeArti.FolgeTraeArtiID = FolgeTraeArti.ID
JOIN KdArti AS FolgeKdArti ON FolgeTraeArti.KdArtiID = FolgeKdArti.ID
JOIN Artikel AS FolgeArtikel ON FolgeKdArti.ArtikelID = FolgeArtikel.ID
JOIN ArtGroe AS FolgeArtGroe ON FolgeTraeArti.ArtGroeID = FolgeArtGroe.ID
WHERE Kunden.KdNr = 272295
  AND Artikel.ArtikelNr = N'98A3'
  AND FolgeArtikel.ArtikelNr = N'98X3'
  AND FolgeKdArti.Variante = N'KE';