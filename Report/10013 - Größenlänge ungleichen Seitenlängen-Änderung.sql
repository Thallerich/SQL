SELECT Traeger.ID AS TraegerID, Traearti.Id TraeArtiID, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nummer], Vsa.Bez AS [VSA-Bezeichnung], Traeger.Traeger AS [Träger-Nummer], Traeger.Vorname, Traeger.Nachname, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, IIF(PATINDEX('%/%', ArtGroe.Groesse) > 0, SUBSTRING(ArtGroe.Groesse, PATINDEX('%/%', ArtGroe.Groesse) + 1, LEN(ArtGroe.Groesse)), '') AS [Größen-Länge], TraeMass.Mass AS [Änderungs-Länge]
FROM TraeArti
JOIN TraeMass ON TraeMass.TraeArtiID = TraeArti.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN GroePo ON GroePo.GroeKoID = Artikel.GroeKoID AND GroePo.Groesse = ArtGroe.Groesse
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE TraeMass.MassOrtID IN (1, 5003, 5302, 5303)
  AND (IIF(PATINDEX('%/%', ArtGroe.Groesse) > 0, SUBSTRING(ArtGroe.Groesse, PATINDEX('%/%', ArtGroe.Groesse) + 1, LEN(ArtGroe.Groesse)), '')) != CAST(TraeMass.Mass AS nvarchar)
  AND TraeArti.Menge > 0
  AND Traeger.[Status] != N'I'
  AND Vsa.SichtbarID IN ($SICHTBARIDS$)
ORDER BY Kunden.KdNr, [VSA-Nummer], [Träger-Nummer], Artikel.ArtikelNr, GroePo.Folge;