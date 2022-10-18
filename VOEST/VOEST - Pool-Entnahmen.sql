SELECT VaterVsa.GebaeudeBez AS Abteilung, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Traeger.Traeger, Traeger.PersNr, Traeger.Vorname, Traeger.Nachname, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, TraeArch.Effektiv AS [Anzahl Pool-Teile], Wochen.Woche
FROM TraeArch
JOIN TraeArti ON TraeArch.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Wochen ON TraeArch.WochenID = Wochen.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Abteil ON TraeArch.AbteilID = Abteil.ID
JOIN Traeger AS VaterTraeger ON Traeger.ParentTraegerID = VaterTraeger.ID
JOIN Vsa AS VaterVsa ON VaterTraeger.VsaID = VaterVsa.ID
WHERE Kunden.KdNr = 272295
  AND Vsa.VsaNr IN (901, 902, 903)
  AND Traeger.ParentTraegerID > 0;