SELECT Traeger.ID AS TraegerID, Traearti.Id TraeArtiID, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nummer], Vsa.Bez AS [VSA-Bezeichnung], Traeger.Traeger AS [Träger-Nummer], Traeger.Vorname, Traeger.Nachname, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, IIF(PATINDEX('%/%', ArtGroe.Groesse) > 0, SUBSTRING(ArtGroe.Groesse, PATINDEX('%/%', ArtGroe.Groesse) + 1, LEN(ArtGroe.Groesse)), '') AS [Größen-Länge], TraeAppl.Mass AS [Änderungs-Länge]
FROM TraeArti
JOIN TraeAppl ON TraeAppl.TraeArtiID = TraeArti.ID
JOIN KdArti AS ApplKdArti ON TraeAppl.ApplKdArtiID = ApplKdArti.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN GroePo ON GroePo.GroeKoID = Artikel.GroeKoID AND GroePo.Groesse = ArtGroe.Groesse
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE ApplKdArti.ArtikelID IN (3806701, 3806724, 3806737, 3806738)
  AND (IIF(PATINDEX('%/%', ArtGroe.Groesse) > 0, SUBSTRING(ArtGroe.Groesse, PATINDEX('%/%', ArtGroe.Groesse) + 1, LEN(ArtGroe.Groesse)), '')) != CAST(TraeAppl.Mass AS nvarchar)
  AND TraeArti.Menge > 0
  AND Traeger.[Status] != N'I'
  AND Vsa.SichtbarID IN ($SICHTBARIDS$)
ORDER BY Kunden.KdNr, [VSA-Nummer], [Träger-Nummer], Artikel.ArtikelNr, GroePo.Folge;